APP="nvim"
REPO="neovim/neovim"
IDIR="${HOME}/.local/nvim"
BDIR="${HOME}/.local/bin"
gup_fetch_release "${REPO}" 'contains("linux-x86_64.tar.gz")'

download() {
    echo "download $1 version"
    echo "installing ${GUP_REL_VERSION}"

    local tmp_dir
    tmp_dir=$(gup_mktemp_dir)
    trap 'rm -rf "${tmp_dir}"' RETURN

    gup_download "${GUP_REL_DL}" "${tmp_dir}/${GUP_REL_FN}"
    rm -rf "${IDIR:?}"
    mkdir -p "${IDIR}"
    tar -zxf "${tmp_dir}/${GUP_REL_FN}" --strip-components=1 -C "${IDIR}"
    ln -sf "${IDIR}/bin/nvim" "${BDIR}/nvim"
}

if [ -z "$(command -v "${APP}")" ]; then
    download new
else
    APPVER=$($(command -v "${APP}") --version 2>&1 | grep -i "^${APP}" | awk '{print $2}' | tr -d 'v')
    if [ "${APPVER}" = "${GUP_REL_VERSION}" ]; then
        echo "${APP} version is current"
    else
        download "${GUP_REL_VERSION}"
    fi
fi
