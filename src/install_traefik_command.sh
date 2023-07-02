CMD="traefik"
REPO="https://github.com/traefik/traefik"
vers=$(git ls-remote --tags ${REPO} | grep "refs/tags.*[0-9]$" | grep -v -e "rc" -e "alpha" -e "beta" | awk '{print $2}' | sed 's/refs\/tags\///' | sort -V | uniq | tail -1)

BDIR=${HOME}/.local/bin

function download(){
    echo "download $1 version"
    echo "Installing ${vers}"
    V=$(echo $vers | sed 's/^v//')
    FN=${CMD}_${vers}_linux_amd64.tar.gz
    rm -f /tmp/${FN}
    wget -qc ${REPO}/releases/download/${vers}/${FN} -O /tmp/${FN}
    mkdir -p /tmp/${CMD}_${vers}
    tar axf /tmp/${FN} -C /tmp/${CMD}_${vers}
    install /tmp/${CMD}_${vers}/${CMD} ${BDIR}/${CMD}
    rm -rf /tmp/${CMD}_${vers} /tmp/${FN}
}

if [ -z $(which ${CMD}) ]; then
    download new
else
    APP=$(which ${CMD})
    APPVER=$(${APP} version | grep ^Version | awk '{print $2}')
    [ "${APPVER}" = "$(echo $vers | sed 's/^v//')" ] && echo "${CMD} version is current" || download new
fi