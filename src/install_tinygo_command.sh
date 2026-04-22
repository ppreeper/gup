APP="tinygo"
REPO="tinygo-org/tinygo"
gup_fetch_release "${REPO}" '(contains("sha256") | not) and contains("linux-amd64.tar.gz")'

download() {
    echo "download $1 version"
    echo "installing ${GUP_REL_VERSION}"

    local tmp_dir
    tmp_dir=$(gup_mktemp_dir)
    trap 'rm -rf "${tmp_dir}"' RETURN

    gup_download "${GUP_REL_DL}" "${tmp_dir}/${GUP_REL_FN}"
    if [ "$(id -u)" = 0 ]; then
        BDIR="/usr/local/bin"
        IDIR="/usr/local/lib"
        sudo rm -rf "${IDIR}/tinygo"
        sudo mkdir -p "${IDIR}/tinygo"
        _gup_extract_tarball "${tmp_dir}/${GUP_REL_FN}" "${IDIR}/tinygo"
        for f in $(find "${IDIR}/tinygo/bin/" -type f); do
            fname=$(basename "${f}")
            sudo rm -f "${BDIR}/${fname}"
            sudo ln -s "${IDIR}/tinygo/bin/${fname}" "${BDIR}/${fname}"
        done
    else
        BDIR="${HOME}/.local/bin"
        IDIR="${HOME}/.local/share"
        rm -rf "${IDIR}/tinygo"
        mkdir -p "${IDIR}/tinygo"
        _gup_extract_tarball "${tmp_dir}/${GUP_REL_FN}" "${IDIR}/tinygo"
        for f in $(find "${IDIR}/tinygo/bin/" -type f); do
            fname=$(basename "${f}")
            rm -f "${BDIR}/${fname}"
            ln -s "${IDIR}/tinygo/bin/${fname}" "${BDIR}/${fname}"
        done
    fi
}

if [ -z "$(command -v "${APP}")" ]; then
    download new
else
    APPVER=$($(command -v "${APP}") version 2>&1 | awk '{print $3}')
    if [ "v${APPVER}" = "v${GUP_REL_VERSION}" ]; then
        echo "${APP} version is current"
        exit 0
    else
        download "${GUP_REL_VERSION}"
    fi
fi
