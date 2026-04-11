APP="yt-dlp"
REPO="yt-dlp/yt-dlp"
RURL="https://api.github.com/repos/${REPO}/releases/latest"
vers=$(wget -qO- "${RURL}" | jq .tag_name | tr -d '"')
DL=$(wget -qO- "${RURL}" | jq '.assets[] | select(.name | contains ("_linux")) | .browser_download_url' | tr -d '"' | grep "_linux$")
FN=$(wget -qO- "${RURL}" | jq '.assets[] | select(.name | contains ("_linux")) | .name' | tr -d '"' | grep "_linux$")

function download() {
    echo "download $1 version"
    echo "installing ${vers}"

    rm -f /tmp/"${FN}"
    wget -qO /tmp/"${FN}" "${DL}"

    if [ "$(id -u)" == 0 ]; then
        BDIR="/usr/local/bin"
        sudo rm -f "${BDIR}/${APP}"
        sudo install /tmp/"${FN}" "${BDIR}/${APP}"
    else
        BDIR="${HOME}/.local/bin"
        rm -f "${BDIR}/${APP}"
        install /tmp/"${FN}" "${BDIR}/${APP}"
    fi

    # cleanup
    rm -f /tmp/"${APP}"
    rm -f /tmp/"${FN}"
}

if [ -z "$(command -v ${APP})" ]; then
    download new
else
    APPVER=$($(command -v ${APP}) --version)
    version=$(echo "${vers}" | sed 's/^v//')
    if [ "${APPVER}" = "${version}" ]; then
        echo "${APP} version is current"
    else
        download "${vers}"
    fi
fi