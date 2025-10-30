APP="upx"
REPO="upx/upx"
RURL="https://api.github.com/repos/${REPO}/releases/latest"
vers=$(wget -qO- "${RURL}" | jq .tag_name | tr -d '"' | tr -d 'v')
DL=$(wget -qO- "${RURL}" | jq '.assets[] | select(.name | (contains("sha256") | not) and contains("amd64_linux.tar.xz")) | .browser_download_url' | tr -d '"')
FN=$(wget -qO- "${RURL}" | jq '.assets[] | select(.name | (contains("sha256") | not) and contains("amd64_linux.tar.xz")) | .name' | tr -d '"')

function download() {
    echo "download $1 version"
    echo "installing ${vers}"
    rm -rf /tmp/"${FN}" /tmp/"${APP}_${vers}"
    wget -qc "${DL}" -O /tmp/"${FN}"
    mkdir -p /tmp/"${APP}_${vers}"
    tar -axf /tmp/"${FN}" -C /tmp/"${APP}_${vers}" --strip-components=1
    if [ "$(id -u)" == 0 ]; then
        BDIR="/usr/local/bin"
        sudo rm -f "${BDIR}/${APP}"
        sudo install /tmp/"${APP}_${vers}/${APP}" "${BDIR}/${APP}"
    else
        BDIR="${HOME}/.local/bin"
        rm -f "${BDIR}/${APP}"
        install /tmp/"${APP}_${vers}/${APP}" "${BDIR}/${APP}"
    fi
    rm -rf /tmp/"${FN}" /tmp/"${APP}_${vers}"
}

if [ -z "$(which "${APP}")" ]; then
    download new
else
    APPVER=$($(which "${APP}") -V 2>&1 | grep -e "^${APP}" | awk '{print $2}')
    if [ "${APPVER}" = "${vers}" ]; then
        echo "${APP} version is current"
    else
        download "${vers}"
    fi
fi