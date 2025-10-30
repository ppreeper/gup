APP="tailwindcss"
REPO="tailwindlabs/tailwindcss"
RURL="https://api.github.com/repos/${REPO}/releases/latest"
vers=$(wget -qO- "${RURL}" | jq .tag_name | tr -d '"' | tr -d 'v')
DL=$(wget -qO- "${RURL}" | jq '.assets[] | select(.name | contains("linux-x64") and (contains("musl") | not)) | .browser_download_url' | tr -d '"')
FN=$(wget -qO- "${RURL}" | jq '.assets[] | select(.name | contains("linux-x64") and (contains("musl") | not)) | .name' | tr -d '"')

download() {
    echo "download $1 version"
    echo "installing ${vers}"
    rm -rf /tmp/"${FN}"
    wget -qc "${DL}" -O /tmp/"${FN}"
    if [ "$(id -u)" == 0 ]; then
        BDIR="/usr/local/bin"
        sudo rm -f "${BDIR}/${APP}"
        sudo install /tmp/"${FN}" "${BDIR}/${APP}"
    else
        BDIR="${HOME}/.local/bin"
        rm -f "${BDIR}/${APP}"
        install /tmp/"${FN}" "${BDIR}/${APP}"
    fi
    rm -rf /tmp/"${FN}"
}

if [ -z "$(which ${APP})" ]; then
    download new
else
    APPVER=$($(which ${APP}) --help 2>&1 | grep "${APP}.*v" | awk '{print $3}' | tr -d 'v')
    if [ "${APPVER}" = "${vers}" ]; then
        echo "${APP} version is current"
    else
        download "${vers}"
    fi
fi
