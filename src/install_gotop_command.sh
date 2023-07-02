CMD="gotop"
REPO="https://github.com/xxxserxxx/gotop"
vers=$(git ls-remote --tags ${REPO} | grep "refs/tags.*[0-9]$" | awk '{print $2}' | sed 's/refs\/tags\///' | sort -V | uniq | tail -1)

BDIR="${HOME}/.local/bin"

function download() {
    echo "download $1 version"
    echo "Installing ${vers}"
    FN=${CMD}_${vers}_linux_amd64.tgz
    rm -f /tmp/${FN}
    wget -qc ${REPO}/releases/download/${vers}/${FN} -O /tmp/${FN}
    rm -f ${BDIR}/${CMD}
    tar axf /tmp/${FN} -C ${BDIR}
    rm -f /tmp/${FN}
}

if [ -z $(which ${CMD}) ]; then
    download new
else
    APP=$(which ${CMD})
    APPVER=$(${APP} --version 2>/dev/null | grep ^gotop | awk '{print $2}')
    [ "${APPVER}" = "${vers}" ] && echo "${CMD} version is current" || download new
fi