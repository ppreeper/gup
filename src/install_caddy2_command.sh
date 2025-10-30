APP="caddy"
REPO="caddyserver/caddy"
RURL="https://api.github.com/repos/${REPO}/releases/latest"
vers=$(wget -qO- "${RURL}" | jq .tag_name | tr -d '"' | tr -d 'v')
DL=$(wget -qO- "${RURL}" | jq '.assets[] | select(.name | (contains(".sig") | not) and contains("linux_amd64.tar.gz")) | .browser_download_url' | tr -d '"')
FN=$(wget -qO- "${RURL}" | jq '.assets[] | select(.name | (contains(".sig") | not) and contains("linux_amd64.tar.gz")) | .name' | tr -d '"')

download() {
    echo "download $1 version"
    echo "installing ${vers}"
    rm -f /tmp/"${FN}" /tmp/"${APP}_${vers}"
    wget -qc "${DL}" -O /tmp/"${FN}"
    mkdir -p /tmp/"${APP}_${vers}"
    tar axf /tmp/"${FN}" -C /tmp/"${APP}_${vers}"
    if [ "$(id -u)" == 0 ]; then
        BDIR="/usr/local/bin"
        sudo rm -f "${BDIR}"/${APP}
        sudo install /tmp/"${APP}_${vers}"/${APP} "${BDIR}"
    else
        BDIR="${HOME}/.local/bin"
        rm -f "${BDIR}"/${APP}
        install /tmp/"${APP}_${vers}"/${APP} "${BDIR}"
    fi
    rm -rf /tmp/"${FN}" /tmp/"${APP}_${vers}"
}

if [ -z "$(which ${APP})" ]; then
    download new
else
    APPVER=$($(which ${APP}) version 2>&1 | grep -i "^v" | awk '{print $1}')
    if [ "${APPVER}" = "${vers}" ]; then
        echo "${APP} version is current"
    else
        download "${vers}"
    fi
fi
