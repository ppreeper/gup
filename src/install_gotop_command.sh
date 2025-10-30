APP="gotop"
REPO="xxxserxxx/gotop"
RURL="https://api.github.com/repos/${REPO}/releases/latest"
vers=$(wget -qO- "${RURL}" | jq .tag_name | tr -d '"' | tr -d 'v')


function download() {
    echo "download $1 version"
    echo "installing ${vers}"
    DL=$(wget -qO- "${RURL}" | jq '.assets[] | select(.name | contains ("linux_amd64.tgz")) | .browser_download_url' | tr -d '"')
    FN=$(wget -qO- "${RURL}" | jq '.assets[] | select(.name | contains ("linux_amd64.tgz")) | .name' | tr -d '"')
    rm -f /tmp/"${FN}"
    wget -qc "${DL}" -O /tmp/"${FN}"
    rm -f "${BDIR}/${APP}"
    if [ "$(id -u)" == 0 ]; then
        BDIR="/usr/local/bin"
        tar axf /tmp/"${FN}" -C "${BDIR}"
    else
        BDIR="${HOME}/.local/bin"
        tar axf /tmp/"${FN}" -C "${BDIR}"
    fi
    rm -f /tmp/"${FN}"
}

if [ -z "$(which ${APP})" ]; then
    download new
else
    APPVER=$($(which ${APP}) --version 2>&1 | grep ^${APP} | awk '{print $2}')
    if [ "${APPVER}" = "${vers}" ]; then
        echo "${APP} version is current"
    else
        download "${vers}"
    fi
fi