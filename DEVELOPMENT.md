# DEVELOPMENT

## Project Structure

```
gup
├── Makefile              # Build: `make` (runs shelly)
├── gup                   # Generated POSIX sh CLI script (DO NOT EDIT)
├── src/
│   ├── lib/
│   │   └── helpers.sh    # Shared helper functions
│   ├── install_*.sh      # Install command source files
│   ├── shelly.yml        # Shelly configuration
│   └── ...
```

## Build

```sh
make          # regenerate gup from src/ using shelly
```

Shelly reads `src/shelly.yml` for commands, arguments, and global structure, and embeds the matching `src/*_command.sh` files into the generated `gup` script.

## Adding a New Install Command

1. Create `src/install_<name>_command.sh`
2. Run `make` to regenerate the `gup` script
3. The command becomes available as `gup install <name>`

## Helper Functions

All helpers are defined in `src/lib/helpers.sh` and are available inside every install script.

### `gup_fetch_release` — Single API Call

Fetches the latest GitHub release with **one** HTTP request. Sets four globals:

| Global | Content |
|--------|---------|
| `GUP_REL_VERSION` | Version string without leading `v` (e.g. `1.4.6`) |
| `GUP_REL_DL` | Download URL |
| `GUP_REL_FN` | Asset filename |
| `GUP_REL_JSON` | Raw JSON (for custom jq queries) |

```bash
gup_fetch_release <repo> <jq_asset_filter>
```

**Parameters:**
- `repo` — GitHub `owner/repo`
- `jq_asset_filter` — jq expression for `select(.name | ...)`

**Examples:**

```bash
# Simple match
gup_fetch_release "cli/cli" 'contains("linux_amd64.tar.gz")'

# Multiple conditions
gup_fetch_release "astral-sh/ruff" '(contains("sha256") | not) and contains("x86_64-unknown-linux-gnu.tar.gz")'

# Negation
gup_fetch_release "zigtools/zls" '(contains("minisig") | not) and contains("x86_64-linux")'
```

The filter must match **exactly one** asset (the multi-asset `nerdfonts` command is the exception): zero matches fails with "no matching asset found", and two or more produce a multi-line URL that `curl` rejects with `URL rejected: Malformed input to a URL function`. Pitfalls seen in practice:

- `contains` is case-sensitive — sibling repos can differ (`lazygit` ships lowercase `linux_x86_64`, `lazydocker` ships capitalized `Linux_x86_64`). Prefer an anchored case-insensitive regex: `test("linux_x86_64\\.tar\\.gz$"; "i")`.
- Signature siblings like `.sigstore.json` or `.sha256` can ride along on a loose `contains`; exclude them or anchor with `endswith` (see `trivy`, `ruff`, `upx`).
- Asset names change between releases (`btop` dropped `.tbz` for `btop-x86_64-unknown-linux-musl.tar.gz`); if an install starts failing, dump the assets with `gh api repos/<owner>/<repo>/releases/latest --jq '.assets[].name'`.

Both `gup_fetch_release` and `gup_get_latest_release` fetch through `gup_github_api` (below). If the API returns `403` because the anonymous rate limit is exhausted, run `gh auth login` or set `GITHUB_TOKEN`/`GH_TOKEN`.

### `gup_github_api` — GitHub API JSON

Fetches JSON for a REST API path. It prefers an authenticated `gh` CLI (5000 requests/hour) and falls back to `curl`/`wget`, sending an `Authorization: Bearer` header when `GITHUB_TOKEN` or `GH_TOKEN` is set.

```bash
json=$(gup_github_api "repos/owner/repo/releases/latest")
```

### `gup_download` — Download (curl or wget)

Uses curl if available, falls back to wget.

```bash
gup_download <url> <output_path>
```

**Example:**

```bash
gup_download "${GUP_REL_DL}" "${tmp_dir}/${GUP_REL_FN}"
```

### `gup_mktemp_dir` — Secure Temp Directory

Creates a random temp directory. Always pair with an `EXIT` trap for cleanup.

```bash
gup_mktemp_dir
```

**Example:**

```sh
tmp_dir=$(gup_mktemp_dir)
trap '[ -z "${tmp_dir:-}" ] || rm -rf "${tmp_dir}"' EXIT
```

### `_gup_install_binary` — Install Single Binary

Installs one binary with automatic root/user detection. Sets `BDIR` globally.

```bash
_gup_install_binary <source_path> [dest_name]
```

**Parameters:**
- `source_path` — path to the binary file
- `dest_name` — optional install name (defaults to basename of source)

**Behavior:**
- Root → installs to `/usr/local/bin` with `sudo`
- User → installs to `${HOME}/.local/bin`

**Examples:**

```bash
# Installs as "ruff"
_gup_install_binary "${tmp_dir}/ruff/ruff"

# Installs as "nvim" (from differently-named source)
_gup_install_binary "${tmp_dir}/bin/nvim-linux" "nvim"
```

### `_gup_install_binaries` — Install Multiple Binaries

Installs multiple binaries from the same directory. Sets `BDIR` globally.

```bash
_gup_install_binaries <source_dir> <name> [name ...]
```

**Example:**

```bash
# Installs both "prometheus" and "promtool"
_gup_install_binaries "${tmp_dir}/prometheus" prometheus promtool

# Installs "uv" and "uvx"
_gup_install_binaries "${tmp_dir}/uv" uv uvx
```

### `_gup_extract_tarball` — Extract Tarball

Extracts `.tar.gz`, `.tar.xz`, `.tbz`, etc. Auto-detects compression.

```bash
_gup_extract_tarball <archive> <dest_dir> [strip_components]
```

**Parameters:**
- `archive` — path to the tarball
- `dest_dir` — extraction target (created if missing)
- `strip_components` — optional, defaults to `1`

**Examples:**

```bash
# Standard: strip top-level directory
_gup_extract_tarball "${tmp_dir}/${GUP_REL_FN}" "${tmp_dir}/${APP}"

# No stripping (flat archive, or archive with its own top-level dir)
_gup_extract_tarball "${tmp_dir}/${GUP_REL_FN}" "${tmp_dir}/${APP}" 0
```

Gotcha: archives whose entries are prefixed with `./` (e.g. `./btop/bin/btop`) count `.` as the stripped component, so `strip=1` leaves an extra directory level. `btop` 1.4.7 archives are `./`-prefixed *and* contain their own top-level `btop/` dir, so they are extracted with `strip=0` directly into `tmp_dir`.

### `_gup_extract_zip` — Extract Zip

```bash
_gup_extract_zip <archive> <dest_dir>
```

**Example:**

```bash
_gup_extract_zip "${tmp_dir}/${GUP_REL_FN}" "${tmp_dir}/${APP}"
```

### `gup_ensure_go` — Check Go Is Installed

Exits with error if `go` is not on PATH.

```bash
gup_ensure_go
```

### `gup_get_latest_release` — Get Version Only

Returns only the tag name (with leading `v`). Use `gup_fetch_release` instead for full info.

If the GitHub releases API request fails — for example when a repository only publishes tags and has no releases (404) — it returns the string `latest` so the caller can use `@latest`.

```bash
vers=$(gup_get_latest_release "owner/repo")
```

---

## Patterns

### Pattern A: Standard Binary Download (Most Common)

```bash
APP="myapp"
REPO="owner/myapp"
gup_fetch_release "${REPO}" 'contains("linux_amd64.tar.gz")'

download() {
    echo "download $1 version"
    echo "installing ${GUP_REL_VERSION}"

    tmp_dir=$(gup_mktemp_dir)
    trap '[ -z "${tmp_dir:-}" ] || rm -rf "${tmp_dir}"' EXIT

    gup_download "${GUP_REL_DL}" "${tmp_dir}/${GUP_REL_FN}"
    _gup_extract_tarball "${tmp_dir}/${GUP_REL_FN}" "${tmp_dir}/${APP}"
    _gup_install_binary "${tmp_dir}/${APP}/${APP}"
}

if [ -z "$(command -v "${APP}")" ]; then
    download new
else
    APPVER=$($(command -v "${APP}") --version 2>&1 | grep -i "^${APP}" | awk '{print $2}')
    if [ "${APPVER}" = "${GUP_REL_VERSION}" ]; then
        echo "${APP} version is current"
    else
        download "${GUP_REL_VERSION}"
    fi
fi
```

### Pattern B: Multiple Binaries

```bash
APP="prometheus"
REPO="prometheus/prometheus"
gup_fetch_release "${REPO}" 'contains("linux-amd64.tar.gz")'

download() {
    echo "download $1 version"
    echo "installing ${GUP_REL_VERSION}"

    tmp_dir=$(gup_mktemp_dir)
    trap '[ -z "${tmp_dir:-}" ] || rm -rf "${tmp_dir}"' EXIT

    gup_download "${GUP_REL_DL}" "${tmp_dir}/${GUP_REL_FN}"
    _gup_extract_tarball "${tmp_dir}/${GUP_REL_FN}" "${tmp_dir}/${APP}"
    _gup_install_binaries "${tmp_dir}/${APP}" "${APP}" promtool
}

# ... version check (same as Pattern A)
```

### Pattern C: Zip Archive

```bash
APP="loki"
REPO="grafana/loki"
gup_fetch_release "${REPO}" 'contains("loki-linux-amd64")'

download() {
    echo "download $1 version"
    echo "installing ${GUP_REL_VERSION}"

    tmp_dir=$(gup_mktemp_dir)
    trap '[ -z "${tmp_dir:-}" ] || rm -rf "${tmp_dir}"' EXIT

    gup_download "${GUP_REL_DL}" "${tmp_dir}/${GUP_REL_FN}"
    _gup_extract_zip "${tmp_dir}/${GUP_REL_FN}" "${tmp_dir}/${APP}"
    _gup_install_binary "${tmp_dir}/${APP}/${APP}-linux-amd64" "${APP}"
}

# ... version check (same as Pattern A)
```

### Pattern D: Direct Binary (No Extraction)

```bash
APP="tailwindcss"
REPO="tailwindlabs/tailwindcss"
gup_fetch_release "${REPO}" 'contains("linux-x64") and (contains("musl") | not)'

download() {
    echo "download $1 version"
    echo "installing ${GUP_REL_VERSION}"

    tmp_dir=$(gup_mktemp_dir)
    trap '[ -z "${tmp_dir:-}" ] || rm -rf "${tmp_dir}"' EXIT

    gup_download "${GUP_REL_DL}" "${tmp_dir}/${GUP_REL_FN}"
    _gup_install_binary "${tmp_dir}/${GUP_REL_FN}"
}

# ... version check (same as Pattern A)
```

### Pattern E: Custom Install (Special Directories)

For tools that install to non-standard locations (e.g. `/usr/local/lib` + symlinks):

```bash
APP="go"
REPO="https://go.googlesource.com/go"
DLREPO="https://dl.google.com/go"
vers=$(git ls-remote --tags "${REPO}" | grep -E 'refs/tags/go[0-9]+\.[0-9]+(\.[0-9]+)?$' | awk '{print $2}' | sed 's/refs\/tags\///' | sort -V | uniq | tail -1)

IDIR=/usr/local/lib
BDIR=/usr/local/bin

download() {
    echo "download $1 version"
    echo "installing $vers"

    tmp_dir=$(gup_mktemp_dir)
    trap '[ -z "${tmp_dir:-}" ] || rm -rf "${tmp_dir}"' EXIT

    FN="${vers}.linux-amd64.tar.gz"
    gup_download "${DLREPO}/${FN}" "${tmp_dir}/${FN}"
    sudo rm -rf "${IDIR}/go"
    sudo tar axf "${tmp_dir}/${FN}" -C "${IDIR}"
    sudo ls "${IDIR}/go/bin" | sudo xargs -I {} ln -sf "${IDIR}/go/bin/{}" "${BDIR}/{}"
}

# ... version check (same as Pattern A)
```

---

## jq Filter Tips

The `gup_fetch_release` jq filter is passed to `select(.name | ...)`. Common patterns:

| Goal | Filter |
|------|--------|
| Simple substring | `'contains("linux_amd64")'` |
| Multiple conditions (AND) | `'contains("extended") and contains("linux-amd64.tar.gz")'` |
| Negation (NOT) | `'(contains("sha256") \| not) and contains("linux-amd64.tar.gz")'` |
| Match at end | `'endswith(".tar.gz")'` |
| Multiple options (OR) | `'contains("linux-amd64") or contains("linux_x86_64")'` |

---

## Conventions

- Write POSIX `sh`, not bash — shelly emits `#!/bin/sh`
- Use `==` → use `=` in `[ ]` tests (POSIX-compliant)
- Always quote variables: `"${APP}"` not `${APP}`
- Do not use `local` (not POSIX); command scripts run in their own invocation
- Wrap JSON in `printf '%s\n'`, not `echo` (backslash handling is implementation-defined)
- Always pair `gup_mktemp_dir` with `trap '[ -z "${tmp_dir:-}" ] || rm -rf "${tmp_dir}"' EXIT`
- Do NOT use predictable `/tmp/` paths — symlink attack vector
- The `download()` function name is conventional; it becomes global when embedded by shelly
