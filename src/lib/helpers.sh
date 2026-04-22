set -euo pipefail

gup_ensure_go() {
    local missing_deps=()
    for dep in go; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing_deps+=("$dep")
        fi
    done

    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo "Missing go: please install Go (run 'gup install go')" >&2
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
    local url="$1"
    local output="$2"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL -o "$output" "$url" || return 1
    else
        wget -qO "$output" "$url" || return 1
    fi
}

# get the latest release tag from GitHub API
# uses curl if available, falls back to wget
gup_get_latest_release() {
    local repo="$1"
    local api_url="https://api.github.com/repos/${repo}/releases/latest"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "${api_url}" | jq -r .tag_name
    else
        wget -qO- "${api_url}" | jq -r .tag_name
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
    local repo="$1"
    local jq_filter="$2"
    local api_url="https://api.github.com/repos/${repo}/releases/latest"
    if command -v curl >/dev/null 2>&1; then
        GUP_REL_JSON=$(curl -fsSL "${api_url}")
    else
        GUP_REL_JSON=$(wget -qO- "${api_url}")
    fi
    if [ -z "${GUP_REL_JSON}" ]; then
        echo "Error: failed to fetch release info for ${repo}" >&2
        return 1
    fi
    GUP_REL_VERSION=$(echo "${GUP_REL_JSON}" | jq -r '.tag_name' | sed 's/^v//')
    GUP_REL_DL=$(echo "${GUP_REL_JSON}" | jq -r ".assets[] | select(.name | ${jq_filter}) | .browser_download_url")
    GUP_REL_FN=$(echo "${GUP_REL_JSON}" | jq -r ".assets[] | select(.name | ${jq_filter}) | .name")
    if [ -z "${GUP_REL_DL}" ]; then
        echo "Error: no matching asset found for ${repo} with filter: ${jq_filter}" >&2
        return 1
    fi
}

# _gup_install_binary src_path [dest_name]
# Installs a single binary with root/user detection.
# Sets BDIR globally.
_gup_install_binary() {
    local src="$1"
    local name="${2:-$(basename "$1")}"
    if [ "$(id -u)" = 0 ]; then
        BDIR="/usr/local/bin"
        mkdir -p "${BDIR}"
        rm -f "${BDIR}/${name}"
        install -m 0755 "${src}" "${BDIR}/${name}"
    else
        BDIR="${HOME}/.local/bin"
        mkdir -p "${BDIR}"
        rm -f "${BDIR}/${name}"
        install -m 0755 "${src}" "${BDIR}/${name}"
    fi
}

# _gup_install_binaries src_dir name [name ...]
# Installs multiple binaries from a directory with root/user detection.
# Sets BDIR globally.
_gup_install_binaries() {
    local src_dir="$1"
    shift
    if [ "$(id -u)" = 0 ]; then
        BDIR="/usr/local/bin"
        mkdir -p "${BDIR}"
        for name in "$@"; do
            rm -f "${BDIR}/${name}"
            install -m 0755 "${src_dir}/${name}" "${BDIR}/${name}"
        done
    else
        BDIR="${HOME}/.local/bin"
        mkdir -p "${BDIR}"
        for name in "$@"; do
            rm -f "${BDIR}/${name}"
            install -m 0755 "${src_dir}/${name}" "${BDIR}/${name}"
        done
    fi
}

# _gup_extract_tarball archive dest_dir [strip_components]
# Extracts a tarball to the destination directory.
_gup_extract_tarball() {
    local archive="$1"
    local dest="$2"
    local strip="${3:-1}"
    mkdir -p "${dest}"
    tar -axf "${archive}" -C "${dest}" --strip-components="${strip}"
}

# _gup_extract_zip archive dest_dir
# Extracts a zip to the destination directory.
_gup_extract_zip() {
    local archive="$1"
    local dest="$2"
    mkdir -p "${dest}"
    unzip -o "${archive}" -d "${dest}"
}

# _gup_symlink_binaries src_dir [pattern]
# Creates symlinks for all binaries in src_dir to BDIR.
# Sets BDIR globally based on root/user detection.
_gup_symlink_binaries() {
    local src_dir="$1"
    if [ "$(id -u)" = 0 ]; then
        BDIR="/usr/local/bin"
        mkdir -p "${BDIR}"
    else
        BDIR="${HOME}/.local/bin"
        mkdir -p "${BDIR}"
    fi
    find "${src_dir}" -maxdepth 1 -type f -executable -exec sh -c '
        for f; do
            ln -sf "$f" "${BDIR}/$(basename "$f")"
        done
    ' _ {} +
}
