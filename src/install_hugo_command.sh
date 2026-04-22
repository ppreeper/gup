APP="hugo"
REPO="gohugoio/hugo"
gup_fetch_release "${REPO}" 'contains("extended") and contains("linux-amd64.tar.gz") and (contains("withdeploy") | not)'

download() {
    echo "download $1 version"
    echo "installing ${GUP_REL_VERSION}"

    local tmp_dir
    tmp_dir=$(gup_mktemp_dir)
    trap 'rm -rf "${tmp_dir}"' RETURN

    gup_download "${GUP_REL_DL}" "${tmp_dir}/${GUP_REL_FN}"
    if [ "$(id -u)" = 0 ]; then
        BDIR="/usr/local/bin"
        sudo tar -axf "${tmp_dir}/${GUP_REL_FN}" -C "${BDIR}" "${APP}"
    else
        BDIR="${HOME}/.local/bin"
        tar -axf "${tmp_dir}/${GUP_REL_FN}" -C "${BDIR}" "${APP}"
    fi
}

if [ -z "$(command -v "${APP}")" ]; then
    download new
else
    APPVER=$($(command -v "${APP}") version 2>&1 | awk '{print $2}' | awk -F'-' '{print $1}')
    if [ "${APPVER}" = "${GUP_REL_VERSION}" ]; then
        echo "${APP} version is current"
    else
        download "${GUP_REL_VERSION}"
    fi
fi
