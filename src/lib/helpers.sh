set -eu

gup_ensure_go() {
    if ! command -v go >/dev/null 2>&1; then
        echo "Missing go: please install Go (run 'gup install go')" >&2
        exit 1
    fi
}

gup_ensure_node() {
    if ! command -v node >/dev/null 2>&1; then
        echo "Missing node: please install nodejs (run 'gup install nodejs')" >&2
        exit 1
    fi
}

# Abort if not running as root
_gup_require_root() {
    if [ "$(id -u)" != 0 ]; then
        echo "Error: ${1:-this command} requires root privileges" >&2
        exit 1
    fi
}

# download using curl or wget
# returns 1 on failure
gup_download() {
    url="$1"
    output="$2"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL -o "$output" "$url" || return 1
    else
        wget -qO "$output" "$url" || return 1
    fi
}

# fetch GitHub API JSON for a path such as repos/owner/repo/releases/latest
# prefers an authenticated `gh` CLI (5000 req/h), then falls back to
# curl/wget, honouring GITHUB_TOKEN or GH_TOKEN when set
gup_github_api() {
    path="$1"
    if command -v gh >/dev/null 2>&1; then
        if gh api "${path}" 2>/dev/null; then
            return 0
        fi
    fi
    token="${GITHUB_TOKEN:-${GH_TOKEN:-}}"
    api_url="https://api.github.com/${path}"
    if command -v curl >/dev/null 2>&1; then
        if [ -n "${token}" ]; then
            curl -fsSL -H "Authorization: Bearer ${token}" "${api_url}"
        else
            curl -fsSL "${api_url}"
        fi
    else
        if [ -n "${token}" ]; then
            wget -qO- --header="Authorization: Bearer ${token}" "${api_url}"
        else
            wget -qO- "${api_url}"
        fi
    fi
}

# get the latest release tag from GitHub API
# falls back to "latest" when the repository has no releases
# (e.g. it only publishes tags), so tools can use @latest
gup_get_latest_release() {
    repo="$1"
    response=$(gup_github_api "repos/${repo}/releases/latest" 2>/dev/null) || response=""
    if [ -z "${response}" ]; then
        echo "latest"
        return 0
    fi
    tag=$(printf '%s' "${response}" | jq -r '.tag_name // empty' 2>/dev/null)
    if [ -z "${tag}" ] || [ "${tag}" = "null" ]; then
        echo "latest"
    else
        echo "${tag}"
    fi
}

# create a secure temporary directory
gup_mktemp_dir() {
    mktemp -d
}

# gup_fetch_release repo jq_asset_filter
# Fetches latest GitHub release info with a single API call.
# Sets globals: GUP_REL_VERSION (no leading v), GUP_REL_DL, GUP_REL_FN, GUP_REL_JSON
gup_fetch_release() {
    repo="$1"
    jq_filter="$2"
    GUP_REL_JSON=$(gup_github_api "repos/${repo}/releases/latest" 2>/dev/null) || GUP_REL_JSON=""
    if [ -z "${GUP_REL_JSON}" ]; then
        echo "Error: failed to fetch release info for ${repo}" >&2
        echo "Hint: the GitHub API rate limit may be exhausted; run 'gh auth login' or set GITHUB_TOKEN." >&2
        return 1
    fi
    GUP_REL_VERSION=$(printf '%s\n' "${GUP_REL_JSON}" | jq -r '.tag_name' | sed 's/^v//')
    GUP_REL_DL=$(printf '%s\n' "${GUP_REL_JSON}" | jq -r ".assets[] | select(.name | ${jq_filter}) | .browser_download_url")
    GUP_REL_FN=$(printf '%s\n' "${GUP_REL_JSON}" | jq -r ".assets[] | select(.name | ${jq_filter}) | .name")
    if [ -z "${GUP_REL_DL}" ]; then
        echo "Error: no matching asset found for ${repo} with filter: ${jq_filter}" >&2
        return 1
    fi
}

# _gup_install_binary src_path [dest_name]
# Installs a single binary with root/user detection.
# Sets BDIR globally.
_gup_install_binary() {
    src="$1"
    if [ "$#" -ge 2 ]; then
        name="$2"
    else
        name=${1##*/}
    fi
    if [ "$(id -u)" = 0 ]; then
        BDIR="/usr/local/bin"
    else
        BDIR="${HOME}/.local/bin"
    fi
    mkdir -p "${BDIR}"
    rm -f "${BDIR}/${name}"
    install -m 0755 "${src}" "${BDIR}/${name}"
}

# _gup_install_binaries src_dir name [name ...]
# Installs multiple binaries from a directory with root/user detection.
# Sets BDIR globally.
_gup_install_binaries() {
    src_dir="$1"
    shift
    if [ "$(id -u)" = 0 ]; then
        BDIR="/usr/local/bin"
    else
        BDIR="${HOME}/.local/bin"
    fi
    mkdir -p "${BDIR}"
    for name in "$@"; do
        rm -f "${BDIR}/${name}"
        install -m 0755 "${src_dir}/${name}" "${BDIR}/${name}"
    done
}

# _gup_extract_tarball archive dest_dir [strip_components]
# Extracts a tarball to the destination directory.
_gup_extract_tarball() {
    archive="$1"
    dest="$2"
    strip="${3:-1}"
    mkdir -p "${dest}"
    case "${archive}" in
        *.tar.gz|*.tgz) tar -xzf "${archive}" -C "${dest}" --strip-components="${strip}" ;;
        *.tar.xz)       tar -xJf "${archive}" -C "${dest}" --strip-components="${strip}" ;;
        *.tar.bz2)      tar -xjf "${archive}" -C "${dest}" --strip-components="${strip}" ;;
        *)              tar -xf  "${archive}" -C "${dest}" --strip-components="${strip}" ;;
    esac
}

# _gup_extract_zip archive dest_dir
# Extracts a zip to the destination directory.
_gup_extract_zip() {
    archive="$1"
    dest="$2"
    mkdir -p "${dest}"
    unzip -o "${archive}" -d "${dest}"
}

# _gup_symlink_binaries src_dir [pattern]
# Creates symlinks for all binaries in src_dir to BDIR.
# Sets BDIR globally based on root/user detection.
_gup_symlink_binaries() {
    src_dir="$1"
    if [ "$(id -u)" = 0 ]; then
        BDIR="/usr/local/bin"
    else
        BDIR="${HOME}/.local/bin"
    fi
    mkdir -p "${BDIR}"
    for f in "${src_dir}"/*; do
        [ -f "$f" ] && [ -x "$f" ] || continue
        ln -sf "$f" "${BDIR}/${f##*/}"
    done
}
