set -euo pipefail

APP="fj"
REPO="forgejo-contrib/forgejo-cli"
API_URL="https://codeberg.org/api/v1/repos/${REPO}/releases/latest"

get_latest_version() {
    local version
    version=$(wget -qO- "${API_URL}" | grep -o '"tag_name":"[^"]*"' | head -1 | cut -d'"' -f4)
    echo "${version}"
}

download() {
    local version
    version=$(get_latest_version)
    echo "download ${APP} ${version}"

    local DL="https://codeberg.org/${REPO}/releases/download/${version}/forgejo-cli-x86_64-linux.tar.gz"
    local FN="forgejo-cli-x86_64-linux.tar.gz"

    local tmp_dir
    tmp_dir=$(gup_mktemp_dir)
    trap '[ -z "${tmp_dir:-}" ] || rm -rf "${tmp_dir}"' RETURN

    gup_download "${DL}" "${tmp_dir}/${FN}"
    tar -axf "${tmp_dir}/${FN}" -C "${tmp_dir}"

    if [ "$(id -u)" = 0 ]; then
        BDIR="/usr/local/bin"
    else
        BDIR="${HOME}/.local/bin"
        mkdir -p "${BDIR}"
    fi

    install -Dm755 "${tmp_dir}/${APP}" "${BDIR}/${APP}"
}

download new
