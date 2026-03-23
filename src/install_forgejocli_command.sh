APP="fj"
DL="https://codeberg.org/forgejo-contrib/forgejo-cli/releases/download/latest/forgejo-cli-linux.tar.gz"
FN="forgejo-cli-linux.tar.gz"

BDIR=/usr/local/bin

function download() {
    echo "download $1 version"
    echo "installing ${vers}"
    sudo rm -f /tmp/"${FN}"
    sudo rm -f /tmp/"${APP}"
    wget -qc "${DL}" -O /tmp/"${FN}"
    sudo tar -axf /tmp/"${FN}" -C /tmp
    ls -l /tmp
    sudo rm -rf "${BDIR}/${APP}"
    sudo install -Dm755 /tmp/"${APP}" "${BDIR}/${APP}"
    sudo rm -f /tmp/"${FN}"
    sudo rm -f /tmp/"${APP}"
}

download new