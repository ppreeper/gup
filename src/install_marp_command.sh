APP="marp"
REPO="marp-team/marp-cli"
RURL="https://api.github.com/repos/${REPO}/releases/latest"
vers=$(wget -qO- "${RURL}" | jq .tag_name | tr -d '"' | tr -d 'v')
DL=$(wget -qO- "${RURL}" | jq '.assets[] | select(.name | contains ("linux")) | .browser_download_url' | tr -d '"')
FN=$(wget -qO- "${RURL}" | jq '.assets[] | select(.name | contains ("linux")) | .name' | tr -d '"')

download() {
    echo "download $1 version"
    echo "installing ${vers}"
    rm -f "/tmp/${FN}" /tmp/"${APP}"
    wget -qc "${DL}" -O "/tmp/${FN}"
    tar axf "/tmp/${FN}" -C /tmp/ "${APP}"
    if [ "$(id -u)" == 0 ]; then
        BDIR="/usr/local/bin"
        sudo rm -f "${BDIR}"/${APP}
        sudo install /tmp/"${APP}" "${BDIR}"
    else
        BDIR="${HOME}/.local/bin"
        rm -f "${BDIR}"/${APP}
        install /tmp/"${APP}" "${BDIR}"
    fi
    rm -f "/tmp/${FN}" /tmp/"${APP}"
}

if [ -z "$(which ${APP})" ]; then
    download new
else
    APPVER=$($(which ${APP}) --version 2>&1 | grep marp-cli | awk '{print $2}' | tr -d 'v')
    if [ "${APPVER}" = "${vers}" ]; then
        echo "${APP} version is current"
    else
        download "${vers}"
    fi
fi
