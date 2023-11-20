APP="k9s"
REPO="https://github.com/derailed/k9s"
vers=$(git ls-remote --tags ${REPO} | grep "refs/tags.*[0-9]$" | awk '{print $2}' | sed 's/refs\/tags\///' | sort -V | uniq | tail -1)

IDIR="${HOME}/.local/bin"

if [ ${USERIDNUMBER} == 0 ]; then
  IDIR="/usr/local/bin"
fi

function download() {
    echo "download $1 version"
    echo "installing ${vers}"
    mkdir -p ${IDIR}
    FN=k9s-Linux_amd64.tar.gz
    rm -rf /tmp/k9s /tmp/${FN}
    echo wget -qc ${REPO}/releases/download/${vers}/${FN} -O /tmp/${FN}
    tar axf ${FN} /tmp/k9s
    install /tmp/k9s $IDIR
    rm -rf /tmp/k9s /tmp/${FN}
}


if [ -z $(which ${APP}) ]; then
    download new
else
  APPBIN=$(which ${APP})
  APPVER=$(${APPBIN} version | grep -e "^Version" | awk '{print $2}')
  [ "${APPVER}" = "${vers}" ] && echo "${APP} version is current" || download ${vers}
fi
