APP="loki"
REPO="grafana/loki"
gup_fetch_release "${REPO}" 'contains("loki-linux-amd64")'

download() {
    echo "download $1 version"
    echo "installing ${GUP_REL_VERSION}"

    local tmp_dir
    tmp_dir=$(gup_mktemp_dir)
    trap 'rm -rf "${tmp_dir}"' RETURN

    gup_download "${GUP_REL_DL}" "${tmp_dir}/${GUP_REL_FN}"
    _gup_extract_zip "${tmp_dir}/${GUP_REL_FN}" "${tmp_dir}/${APP}"
    _gup_install_binary "${tmp_dir}/${APP}/${APP}-linux-amd64" "${APP}"
}

if [ -z "$(command -v "${APP}")" ]; then
    download new
else
    APPVER=$($(command -v "${APP}") --version 2>&1 | grep -i "^${APP}" | awk '{print $3}')
    if [ "${APPVER}" = "${GUP_REL_VERSION}" ]; then
        echo "${APP} version is current"
    else
        download "${GUP_REL_VERSION}"
    fi
fi
