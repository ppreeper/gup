APP="gh"
REPO="cli/cli"
RURL="https://api.github.com/repos/${REPO}/releases/latest"
vers=$(wget -qO- "${RURL}" | jq .tag_name | tr -d '"' | tr -d 'v')
DL=$(wget -qO- "${RURL}" | jq '.assets[] | select(.name | contains ("linux_amd64.tar.gz")) | .browser_download_url' | tr -d '"')
FN=$(wget -qO- "${RURL}" | jq '.assets[] | select(.name | contains ("linux_amd64.tar.gz")) | .name' | tr -d '"')

IDIR=/usr/local/lib
BDIR=/usr/local/bin

function download() {
    echo "download $1 version"
    echo "installing ${vers}"
    sudo rm -f /tmp/"${FN}"
    wget -qc "${DL}" -O /tmp/"${FN}"
    sudo rm -rf "${IDIR}/${APP}"
    sudo mkdir -p "${IDIR}/${APP}"
    sudo tar -axf /tmp/"${FN}" --strip-components=1 -C "${IDIR}/${APP}"
    sudo ls "${IDIR}/${APP}/bin" | sudo xargs -I {} ln -sf "${IDIR}/${APP}/bin/{}" "${BDIR}/{}"
    sudo rm -f /tmp/"${FN}"
}

if [ -z "$(which ${APP})" ]; then
    download new
else
    APPVER=$($(which ${APP}) version 2>&1 | awk '{print $3}')
    if [ "${APPVER}" = "${vers}" ]; then
        echo "${APP} version is current"
    else
        download "${vers}"
    fi
fi