gup_ensure_go() {
    local missing_deps=()
    for dep in go; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing_deps+=("$dep")
        fi
    done

    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo "Missing go: please install Go \`gup install go\`" >&2
        exit 1
    fi
}

# download using curl or wget
gup_download() {
    local url="$1"
    local output="$2"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL -o "$output" "$url"
    else
        wget -qO "$output" "$url"
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
    mktemp -d "${TMPDIR:-/tmp}/gup.XXXXXXXXXX"
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
    GUP_REL_VERSION=$(echo "${GUP_REL_JSON}" | jq -r '.tag_name' | sed 's/^v//')
    GUP_REL_DL=$(echo "${GUP_REL_JSON}" | jq -r ".assets[] | select(.name | ${jq_filter}) | .browser_download_url")
    GUP_REL_FN=$(echo "${GUP_REL_JSON}" | jq -r ".assets[] | select(.name | ${jq_filter}) | .name")
}

# _gup_install_binary src_path [dest_name]
# Installs a single binary with root/user detection.
# Sets BDIR globally.
_gup_install_binary() {
    local src="$1"
    local name="${2:-$(basename "$1")}"
    if [ "$(id -u)" = 0 ]; then
        BDIR="/usr/local/bin"
        sudo rm -f "${BDIR}/${name}"
        sudo install "${src}" "${BDIR}/${name}"
    else
        BDIR="${HOME}/.local/bin"
        rm -f "${BDIR}/${name}"
        install "${src}" "${BDIR}/${name}"
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
        for name in "$@"; do
            sudo rm -f "${BDIR}/${name}"
            sudo install "${src_dir}/${name}" "${BDIR}/${name}"
        done
    else
        BDIR="${HOME}/.local/bin"
        for name in "$@"; do
            rm -f "${BDIR}/${name}"
            install "${src_dir}/${name}" "${BDIR}/${name}"
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
