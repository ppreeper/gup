set -euo pipefail

APP="stylua"
REPO="JohnnyMorganz/StyLua"
BDIR="${HOME}/.local/bin"
gup_fetch_release "${REPO}" 'contains("linux-x86_64.zip")'

download() {
    echo "download $1 version"
    echo "installing ${GUP_REL_VERSION}"

    local tmp_dir
    tmp_dir=$(gup_mktemp_dir)
    trap '[ -z "${tmp_dir:-}" ] || rm -rf "${tmp_dir}"' RETURN

    gup_download "${GUP_REL_DL}" "${tmp_dir}/${GUP_REL_FN}"
    unzip -o "${tmp_dir}/${GUP_REL_FN}" -d "${tmp_dir}"
    mv "${tmp_dir}/stylua" "${BDIR}/stylua"
    chmod +x "${BDIR}/stylua"
}

if [ -z "$(command -v "${APP}")" ]; then
    download new
else
    APPVER=$($(command -v "${APP}") -V 2>&1 | grep -e "^stylua" | awk '{print $2}')
    if [ "${APPVER}" = "${GUP_REL_VERSION}" ]; then
        echo "${APP} version is current"
    else
        download "${GUP_REL_VERSION}"
    fi
fi