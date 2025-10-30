APP="node_exporter"
REPO="prometheus/node_exporter"
RURL="https://api.github.com/repos/${REPO}/releases/latest"
vers=$(wget -qO- "${RURL}" | jq .tag_name | tr -d '"' | tr -d 'v')
DL=$(wget -qO- "${RURL}" | jq '.assets[] | select(.name | contains("linux-amd64")) | .browser_download_url' | tr -d '"')
FN=$(wget -qO- "${RURL}" | jq '.assets[] | select(.name | contains("linux-amd64")) | .name' | tr -d '"')

BDIR="/usr/local/bin"

download() {
    echo "download $1 version"
    echo "installing ${vers}"
    sudo rm -rf /tmp/${APP}_"${vers}" /tmp/"${FN}"
    wget -qc "${DL}" -O /tmp/"${FN}"
    sudo rm -f ${BDIR}/${APP}
    sudo mkdir -p /tmp/${APP}_"${vers}"
    sudo tar axf /tmp/"${FN}" -C /tmp/${APP}_"${vers}" --strip-components=1
    sudo install /tmp/${APP}_"${vers}"/${APP} ${BDIR}/${APP}
    sudo rm -rf /tmp/${APP}_"${vers}" /tmp/"${FN}"
}

if [ -z "$(which ${APP})" ]; then
    download new
else
    APPVER=$($(which ${APP}) --version 2>&1 | grep -i ^${APP} | awk '{print $3}' | tr -d 'v')
    if [ "${APPVER}" = "$vers" ]; then
        echo "${APP} version is current"
    else
        download "${vers}"
    fi
fi
