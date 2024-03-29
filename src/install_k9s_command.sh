APP="k9s"
REPO="https://github.com/derailed/k9s"
vers=$(git ls-remote --tags ${REPO} | grep "refs/tags.*[0-9]$" | awk '{print $2}' | sed 's/refs\/tags\///' | sort -V | uniq | tail -1)

IDIR="${HOME}/.local/bin"

if [ $(id -u) == 0 ]; then
  IDIR="/usr/local/bin"
fi

function download() {
    echo "download $1 version"
    echo "installing ${vers}"
    mkdir -p ${IDIR}
    FN=k9s_Linux_amd64.tar.gz
    rm -rf /tmp/k9s /tmp/${FN}
    wget -qc ${REPO}/releases/download/${vers}/${FN} -O /tmp/${FN}
    tar axf /tmp/${FN} k9s
    install k9s $IDIR
    rm -rf k9s /tmp/${FN}
}


if [ -z $(which ${APP}) ]; then
    download new
else
  APPBIN=$(which ${APP})
  APPVER=$(${APPBIN} version 2>&1 | grep Version | awk '{print $2}')
  [ "${APPVER}" = "${vers}" ] && echo "${APP} version is current" || download ${vers}
fi
