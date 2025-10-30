APP="doctl"
REPO="digitalocean/doctl"
RURL="https://api.github.com/repos/${REPO}/releases/latest"
vers=$(wget -qO- "${RURL}" | jq .tag_name | tr -d '"' | tr -d 'v')
DL=$(wget -qO- "${RURL}" | jq '.assets[] | select(.name | contains ("linux-amd64")) | .browser_download_url' | tr -d '"')
FN=$(wget -qO- "${RURL}" | jq '.assets[] | select(.name | contains ("linux-amd64")) | .name' | tr -d '"')

function download() {
    echo "download $1 version"
    echo "installing ${vers}"
    wget -qc "${DL}" -O /tmp/"${FN}"
    if [ "$(id -u)" == 0 ]; then
        BDIR="/usr/local/bin"
        sudo tar -axf /tmp/"${FN}" -C "${BDIR}" "${APP}"
    else
        BDIR="${HOME}/.local/bin"
        tar -axf /tmp/"${FN}" -C "${BDIR}" "${APP}"
    fi
    chmod +x "${BDIR}"/"${APP}"
    rm -f /tmp/"${FN}"
}

if [ -z "$(which ${APP})" ]; then
    download new
else
    APPVER=$($(which ${APP}) version 2>&1 | grep "doctl version" | awk '{print $3}' | awk -F'-' '{print $1}')
    if [ "${APPVER}" = "${vers}" ]; then
        echo "${APP} version is current"
    else
        download "${vers}"
    fi
fi