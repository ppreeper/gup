APP="tinygo"
REPO="tinygo-org/tinygo"
RURL="https://api.github.com/repos/${REPO}/releases/latest"
vers=$(wget -qO- "${RURL}" | jq .tag_name | tr -d '"' | tr -d 'v')
DL=$(wget -qO- "${RURL}" | jq '.assets[] | select(.name | (contains("sha256") | not) and contains("linux-amd64.tar.gz")) | .browser_download_url' | tr -d '"')
FN=$(wget -qO- "${RURL}" | jq '.assets[] | select(.name | (contains("sha256") | not) and contains("linux-amd64.tar.gz")) | .name' | tr -d '"')

function download() {
    echo "download $1 version"
    echo "installing ${vers}"
    rm -rf /tmp/"${FN}" /tmp/"${APP}_${vers}"
    wget -qc "${DL}" -O /tmp/"${FN}"
    if [ "$(id -u)" == 0 ]; then
        BDIR="/usr/local/bin"
        IDIR="/usr/local/lib"
        sudo rm -rf "${IDIR}/tinygo"
        sudo mkdir -p "${IDIR}/tinygo"
        sudo tar axf /tmp/"${FN}" -C "${IDIR}/tinygo/" --strip-components=1
        for f in $(find "${IDIR}"/tinygo/bin/ -type f); do
            fname=$(basename "${f}")
            sudo rm -f "${BDIR}/${fname}"
            sudo ln -s "${IDIR}"/tinygo/bin/"${fname}" "${BDIR}/${fname}"
        done
    else
        BDIR="${HOME}/.local/bin"
        IDIR="${HOME}/.local/share"
        rm -rf "${IDIR}/tinygo"
        mkdir -p "${IDIR}/tinygo"
        tar axf /tmp/"${FN}" -C "${IDIR}/tinygo/" --strip-components=1
        for f in $(find "${IDIR}"/tinygo/bin/ -type f); do
            fname=$(basename "${f}")
            rm -f "${BDIR}/${fname}"
            ln -s "${IDIR}"/tinygo/bin/"${fname}" "${BDIR}/${fname}"
        done
    fi
    rm -rf /tmp/"${FN}" /tmp/"${APP}_${vers}"
}

if [ -z "$(which ${APP})" ]; then
    download new
else
    APPVER=$($(which ${APP}) version 2>&1 | awk '{print $3}')
    if [ "v${APPVER}" = "${vers}" ]; then
        echo "${APP} version is current"
        exit 0
    else
        download "${vers}"
    fi
fi