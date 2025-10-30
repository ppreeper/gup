APP="traefik"
REPO="traefik/traefik"
RURL="https://api.github.com/repos/${REPO}/releases/latest"
vers=$(wget -qO- "${RURL}" | jq .tag_name | tr -d '"' | tr -d 'v')
DL=$(wget -qO- "${RURL}" | jq '.assets[] | select(.name | contains ("linux_amd64.tar.gz")) | .browser_download_url' | tr -d '"')
FN=$(wget -qO- "${RURL}" | jq '.assets[] | select(.name | contains ("linux_amd64.tar.gz")) | .name' | tr -d '"')

function download(){
    echo "download $1 version"
    echo "installing ${vers}"
    rm -rf /tmp/"${APP}_${vers}" /tmp/"${FN}"
    wget -qc "${DL}" -O /tmp/"${FN}"
    mkdir -p /tmp/"${APP}_${vers}"
    tar axf /tmp/"${FN}" -C /tmp/"${APP}_${vers}"
    if [ "$(id -u)" == 0 ]; then
        BDIR="/usr/local/bin"
        sudo install /tmp/"${APP}_${vers}"/"${APP}" "${BDIR}/${APP}"
    else
        BDIR="${HOME}/.local/bin"
        install /tmp/"${APP}_${vers}"/"${APP}" "${BDIR}/${APP}"
    fi
    rm -rf /tmp/"${APP}_${vers}" /tmp/"${FN}"
}

if [ -z "$(which ${APP})" ]; then
    download new
else
    APPVER=$($(which ${APP}) version 2>&1 | grep ^Version | awk '{print $2}')
    if [ "${APPVER}" = "${vers}" ]; then
        echo "${APP} version is current"
    else
        download "${vers}"
    fi
fi
