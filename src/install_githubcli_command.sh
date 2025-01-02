APP="gh"
REPO="https://github.com/cli/cli"
vers=$(git ls-remote --tags ${REPO} | grep "refs/tags.*[0-9]$" | awk '{print $2}' | sed 's/refs\/tags\///' | grep "^v" | sort -V | uniq | tail -1)

IDIR=/usr/local/lib
BDIR=/usr/local/bin

function download() {
    echo "download $1 version"
    VERS=$(echo ${vers}| sed 's/^v//')
    echo "installing ${VERS}"
    FN=${APP}_${VERS}_linux_amd64.tar.gz
    rm -f /tmp/${FN}
    wget -qc ${REPO}/releases/download/${vers}/${FN} -O /tmp/${FN}
    sudo rm -rf ${IDIR}/${APP}
    sudo mkdir -p ${IDIR}/${APP}
    sudo tar -axf /tmp/${FN} --strip-components=1 -C ${IDIR}/${APP}
    sudo ls ${IDIR}/${APP}/bin | sudo xargs -I {} ln -sf ${IDIR}/${APP}/bin/{} ${BDIR}/{}
    rm -f /tmp/${FN}
}

if [ -z $(which ${APP}) ]; then
    download new
else
    VERS=$(echo ${vers}| sed 's/^v//')
    APPBIN=$(which ${APP})
    APPVER=$(${APPBIN} version | awk '{print $3}')
    [ "${APPVER}" = "${VERS}" ] && echo "${APP} version is current" || download ${vers}
fi