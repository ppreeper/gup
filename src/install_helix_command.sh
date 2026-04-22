APP="hx"
REPO="helix-editor/helix"
IDIR="${HOME}/.config/helix"
BDIR="${HOME}/.local/helix"
gup_fetch_release "${REPO}" 'contains("x86_64-linux")'

download() {
    echo "download $1 version"
    echo "installing ${GUP_REL_VERSION}"

    local tmp_dir
    tmp_dir=$(gup_mktemp_dir)
    trap 'rm -rf "${tmp_dir}"' RETURN

    mkdir -p "${IDIR}"
    touch "${IDIR}/config.toml"
    gup_download "${GUP_REL_DL}" "${tmp_dir}/${GUP_REL_FN}"
    rm -rf "${BDIR:?}"
    mkdir -p "${BDIR}"
    tar axf "${tmp_dir}/${GUP_REL_FN}" --strip-components=1 -C "${BDIR}"
    ln -sf "${BDIR}/hx" "${HOME}/.local/bin/hx"
}

if [ -z "$(command -v "${APP}")" ]; then
    download new
else
    APPVER=$($(command -v "${APP}") -V 2>&1 | grep -e "^helix" | awk '{print $2}')
    if [ "${APPVER}" = "${GUP_REL_VERSION}" ]; then
        echo "${APP} version is current"
    else
        download "${GUP_REL_VERSION}"
    fi
fi
