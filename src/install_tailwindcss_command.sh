APP="tailwindcss"
REPO="tailwindlabs/tailwindcss"
gup_fetch_release "${REPO}" 'contains("linux-x64") and (contains("musl") | not)'

download() {
    echo "download $1 version"
    echo "installing ${GUP_REL_VERSION}"

    local tmp_dir
    tmp_dir=$(gup_mktemp_dir)
    trap 'rm -rf "${tmp_dir}"' RETURN

    gup_download "${GUP_REL_DL}" "${tmp_dir}/${GUP_REL_FN}"
    _gup_install_binary "${tmp_dir}/${GUP_REL_FN}"
}

if [ -z "$(command -v "${APP}")" ]; then
    download new
else
    APPVER=$($(command -v "${APP}") --help 2>&1 | grep "${APP}.*v" | awk '{print $3}' | tr -d 'v')
    if [ "${APPVER}" = "${GUP_REL_VERSION}" ]; then
        echo "${APP} version is current"
    else
        download "${GUP_REL_VERSION}"
    fi
fi
