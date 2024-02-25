APP="litexl"
REPO="https://github.com/lite-xl/lite-xl"
vers=$(git ls-remote --tags ${REPO} | grep "refs/tags.*[0-9]$" | awk '{print $2}' | sed 's/refs\/tags\///' | grep "^v" | sort -V | uniq | tail -1)

BDIR=${HOME}/.local/bin

function download() {
    echo "download $1 version"
    echo "installing ${vers}"
    mkdir -p ${BDIR}
    FN=LiteXL-${vers}-addons-x86_64.AppImage
    wget -qc ${REPO}/releases/download/${vers}/${FN} -O ${BDIR}/litexl
    chmod +x ${BDIR}/litexl
}

download ${vers}
