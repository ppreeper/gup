APP="hugo"
REPO="gohugoio/hugo"
RURL="https://api.github.com/repos/${REPO}/releases/latest"
vers=$(wget -qO- "${RURL}" | jq .tag_name | tr -d '"' | tr -d 'v')
DL=$(wget -qO- "${RURL}" | jq '.assets[] | select(.name | contains("extended") and contains("linux-amd64.tar.gz") and (contains("withdeploy") | not)) | .browser_download_url' | tr -d '"')
FN=$(wget -qO- "${RURL}" | jq '.assets[] | select(.name | contains("extended") and contains("linux-amd64.tar.gz") and (contains("withdeploy") | not)) | .name' | tr -d '"')

function download() {
    echo "download $1 version"
    echo "installing ${vers}"
    wget -qc "${DL}" -O /tmp/"${FN}"
    if [ "$(id -u)" == 0 ]; then
        BDIR="/usr/local/bin"
        tar -axf /tmp/"${FN}" -C "${BDIR}" hugo
    else
        BDIR="${HOME}/.local/bin"
        tar -axf /tmp/"${FN}" -C "${BDIR}" hugo
    fi
    rm -f /tmp/"${FN}"
}

if [ -z "$(which ${APP})" ]; then
    download new
else
    APPVER=$($(which ${APP}) version 2>&1 | awk '{print $2}' | awk -F'-' '{print $1}')
    if [ "${APPVER}" = "${vers}" ]; then
        echo "${APP} version is current"
    else
        download "${vers}"
    fi
fi