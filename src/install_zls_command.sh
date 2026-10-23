APP="zls"
REPO="zigtools/zls"
gup_fetch_release "${REPO}" '(contains("minisig") | not) and contains("x86_64-linux")'

download() {
    echo "download $1 version"
    echo "installing ${GUP_REL_VERSION}"

    tmp_dir=$(gup_mktemp_dir)
    trap '[ -z "${tmp_dir:-}" ] || rm -rf "${tmp_dir}"' EXIT

    gup_download "${GUP_REL_DL}" "${tmp_dir}/${GUP_REL_FN}"
    # The archive is flat (zls, LICENSE, README.md), so do not strip components.
    _gup_extract_tarball "${tmp_dir}/${GUP_REL_FN}" "${tmp_dir}/${APP}" 0
    _gup_install_binary "${tmp_dir}/${APP}/zls"
}

if [ -z "$(command -v "${APP}")" ]; then
    download new
else
    APPVER=$($(command -v "${APP}") version 2>&1)
    if [ "${APPVER}" = "${GUP_REL_VERSION}" ]; then
        echo "${APP} version is current"
    else
        download "${GUP_REL_VERSION}"
    fi
fi
