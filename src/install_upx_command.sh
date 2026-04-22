set -euo pipefail

APP="upx"
REPO="upx/upx"
gup_fetch_release "${REPO}" '(contains("sha256") | not) and contains("amd64_linux.tar.xz")'

download() {
    echo "download $1 version"
    echo "installing ${GUP_REL_VERSION}"

    local tmp_dir
    tmp_dir=$(gup_mktemp_dir)
    trap 'rm -rf "${tmp_dir}"' RETURN

    gup_download "${GUP_REL_DL}" "${tmp_dir}/${GUP_REL_FN}"
    _gup_extract_tarball "${tmp_dir}/${GUP_REL_FN}" "${tmp_dir}/${APP}"
    _gup_install_binary "${tmp_dir}/${APP}/${APP}"
}

if [ -z "$(command -v "${APP}")" ]; then
    download new
else
    APPVER=$($(command -v "${APP}") -V 2>&1 | grep -e "^${APP}" | awk '{print $2}')
    if [ "${APPVER}" = "${GUP_REL_VERSION}" ]; then
        echo "${APP} version is current"
    else
        download "${GUP_REL_VERSION}"
    fi
fi
