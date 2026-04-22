APP="gh"
REPO="cli/cli"
IDIR="/usr/local/lib"
BDIR="/usr/local/bin"
gup_fetch_release "${REPO}" 'contains("linux_amd64.tar.gz")'

download() {
    echo "download $1 version"
    echo "installing ${GUP_REL_VERSION}"

    local tmp_dir
    tmp_dir=$(gup_mktemp_dir)
    trap 'rm -rf "${tmp_dir}"' RETURN

    gup_download "${GUP_REL_DL}" "${tmp_dir}/${GUP_REL_FN}"
    sudo rm -rf "${IDIR}/${APP}"
    sudo mkdir -p "${IDIR}/${APP}"
    sudo tar -axf "${tmp_dir}/${GUP_REL_FN}" --strip-components=1 -C "${IDIR}/${APP}"
    sudo ls "${IDIR}/${APP}/bin" | sudo xargs -I {} ln -sf "${IDIR}/${APP}/bin/{}" "${BDIR}/{}"
}

if [ -z "$(command -v "${APP}")" ]; then
    download new
else
    APPVER=$($(command -v "${APP}") version 2>&1 | awk '{print $3}')
    if [ "${APPVER}" = "${GUP_REL_VERSION}" ]; then
        echo "${APP} version is current"
    else
        download "${GUP_REL_VERSION}"
    fi
fi
