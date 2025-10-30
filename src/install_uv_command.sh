APP="uv"
REPO="astral-sh/uv"
RURL="https://api.github.com/repos/${REPO}/releases/latest"
vers=$(wget -qO- "${RURL}" | jq .tag_name | tr -d '"' | tr -d 'v')
DL=$(wget -qO- "${RURL}" | jq '.assets[] | select(.name | (contains("sha256") | not) and contains("x86_64-unknown-linux-gnu.tar.gz")) | .browser_download_url' | tr -d '"')
FN=$(wget -qO- "${RURL}" | jq '.assets[] | select(.name | (contains("sha256") | not) and contains("x86_64-unknown-linux-gnu.tar.gz")) | .name' | tr -d '"')

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
        sudo rm -f "${BDIR}/${APP}x"
        sudo install /tmp/"${APP}_${vers}"/"${APP}" "${BDIR}/${APP}"
        sudo install /tmp/"${APP}_${vers}"/"${APP}x" "${BDIR}/${APP}x"
    else
        BDIR="${HOME}/.local/bin"
        rm -f "${BDIR}/${APP}"
        rm -f "${BDIR}/${APP}x"
        install /tmp/"${APP}_${vers}"/"${APP}" "${BDIR}/${APP}"
        install /tmp/"${APP}_${vers}"/"${APP}x" "${BDIR}/${APP}x"
    fi
    rm -rf /tmp/"${FN}" /tmp/"${APP}_${vers}"
}

if [ -z "$(which ${APP})" ]; then
    download new
else
    APPVER=$($(which ${APP}) --version 2>&1 | grep "^${APP}" | awk '{print $2}')
    if [ "${APPVER}" = "${vers}" ]; then
        echo "${APP} version is current"
    else
        download "${vers}"
    fi
fi