APP="tinygo"
REPO="https://github.com/tinygo-org/tinygo"
DLREPO="https://github.com/tinygo-org/tinygo/releases/download"
vers=$(git ls-remote --tags ${REPO} | grep "refs/tags.*[0-9]$" | awk '{print $2}' | sed 's/refs\/tags\///' | grep -v -e "[rc|beta|alpha]" | sort -V | uniq | tail -1)

IDIR=/usr/local/lib
BDIR=/usr/local/bin

function download() {
    echo "download $1 version"
    echo "installing ${vers}"
    VERS=$(echo "${vers}" | sed 's/^v//')
    FN=${APP}${VERS}.linux-amd64.tar.gz
    DLURL="${DLREPO}/${vers}/${FN}"
    rm -f /tmp/"${FN}"
    wget -qc "${DLURL}" -O /tmp/"${FN}"
    sudo rm -rf "${IDIR}/tinygo"
    sudo mkdir -p "${IDIR}/tinygo"
    sudo tar -axf /tmp/"${FN}" -C "${IDIR}/tinygo" --strip-components=1
    sudo ls ${IDIR}/tinygo/bin 2>/dev/null | sudo xargs -I {} rm -f ${BDIR}/{}
    sudo ls ${IDIR}/tinygo/bin 2>/dev/null | sudo xargs -I {} ln -s ${IDIR}/tinygo/bin/{} ${BDIR}/{}
    rm -f /tmp/"${FN}"
}

if [ -z "$(which ${APP})" ]; then
    download new
else
    APPBIN=$(which ${APP})
    APPVER=$(${APPBIN} version | grep version | awk '{print $3}')
    if [ "v${APPVER}" = "${vers}" ]; then
        echo "${APP} version is current"
        exit 0
    else
        download "${vers}"
    fi
fi