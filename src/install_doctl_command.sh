APP="doctl"
REPO="https://github.com/digitalocean/doctl"
vers=$(git ls-remote --tags ${REPO} | grep "refs/tags.*[0-9]$" | awk '{print $2}' | sed 's/refs\/tags\///g' | sort -V | uniq | tail -1)

if [ $(id -u) == 0 ]; then
  BDIR="/usr/local/bin"
else
  BDIR="${HOME}/.local/bin"
fi

function download() {
    echo "download $1 version"
    echo "installing ${vers}"
    V=$(echo ${vers} | sed 's/^v//')
    FN=${APP}-${V}-linux-amd64.tar.gz
    DF=${APP}.tar.gz
    wget -qc ${REPO}/releases/download/${vers}/${FN} -O /tmp/${DF}
    tar -axf /tmp/${DF} -C ${BDIR} ${APP}
    chmod +x ${BDIR}/${APP}
    rm -f /tmp/${DF}
}

if [ -z $(which ${APP}) ]; then
    download new
else
    APPBIN=$(which ${APP})
    APPVER=$(${APPBIN} version | awk '{print $2}' | awk -F'-' '{print $1}')
    [ "${APPVER}" = "${vers}" ] && echo "${APP} version is current" || download ${vers}
fi