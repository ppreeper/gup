APP="prometheus"
REPO="https://github.com/prometheus/prometheus"
vers=$(git ls-remote --tags ${REPO} | grep "refs/tags.*[0-9]$" | grep -v -e rc -e alpha -e beta | awk '{print $2}' | sed 's/refs\/tags\///' | sort -V | uniq | tail -1)

BDIR="/usr/local/bin"
BDIR="${HOME}/.local/bin"

download() {
    echo "download $1 version"
    echo "installing ${vers}"
    V=$(echo $vers | sed 's/v//')
    FN=${APP}-${V}.linux-amd64.tar.gz
    rm -f /tmp/${FN}
    wget -qc ${REPO}/releases/download/${vers}/${FN} -O /tmp/${FN}
    rm -f ${BDIR}/${APP}
    rm -f ${BDIR}/promtool
    mkdir -p /tmp/${APP}_${vers}
    tar axf /tmp/${FN} -C /tmp/${APP}_${vers} --strip-components=1
    install /tmp/${APP}_${vers}/${APP} ${BDIR}/${APP}
    install /tmp/${APP}_${vers}/promtool ${BDIR}/promtool
    rm -rf /tmp/${APP}_${vers} /tmp/${FN}
}

if [ -z "$(which ${APP})" ]; then
  download new
else
  APPBIN=$(which ${APP})
  APPVER=$(${APPBIN} --version 2>&1 | grep -i ^${APP} | awk '{print $3}')
  [ "${APPVER}" = "$(echo $vers | sed 's/^v//')" ] && echo "${CMD} version is current" || download ${vers}
fi
