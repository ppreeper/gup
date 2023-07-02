CMD="snmp_exporter"
REPO="https://github.com/prometheus/${CMD}"
vers=$(git ls-remote --tags ${REPO} | grep "refs/tags.*[0-9]$" | grep -v -e "rc" -e "alpha" -e "beta" | awk '{print $2}' | sed 's/refs\/tags\///g' | sort -V | uniq | tail -1)

BDIR=/usr/local/bin
BDIR=${HOME}/.local/bin
IDIR=${HOME}/.local/$CMD

function download() {
    echo "download $1 version"
    echo "Installing ${vers}"
    V=$(echo $vers | sed 's/^v//')
    FN=${CMD}-${V}.linux-amd64.tar.gz
    rm -f /tmp/${FN}
    wget -qc ${REPO}/releases/download/${vers}/${FN} -O /tmp/${FN}
    mkdir -p ${IDIR}
    rm -rf ${IDIR}/*
    tar -zxf /tmp/${FN} --strip-components=1 -C ${IDIR}
    ln -sf ${IDIR}/$CMD ${BDIR}/$CMD
    rm -f /tmp/${FN}
}

if [ -z $(which ${CMD}) ]; then
    download new
else
    APP=$(which ${CMD})
    APPVER=$(${APP} --version | grep -i "^${CMD}" | awk '{print $2}')
    [ "${APPVER}" = "${vers}" ] && echo "${CMD} version is current" || download new
fi