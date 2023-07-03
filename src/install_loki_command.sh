APP="loki"
REPO="https://github.com/grafana/loki"
vers=$(git ls-remote --tags ${REPO} | grep "refs/tags.*[0-9]$" | grep -v -e "helm" | awk '{print $2}' | sed 's/refs\/tags\///' | sort -V | uniq | tail -1)

BDIR="/usr/local/bin"
BDIR="${HOME}/.local/bin"

download() {
    echo "download $1 version"
    echo "installing ${vers}"
    FN=${APP}-linux-amd64.zip
    rm -rf /tmp/${APP}_${vers} /tmp/${FN}
    wget -qc ${REPO}/releases/download/${vers}/${FN} -O /tmp/${FN}
    mkdir -p /tmp/${APP}_${vers}
    unzip /tmp/${FN} -d /tmp/${APP}_${vers}
    rm -f ${BDIR}/${APP}
    install /tmp/${APP}_${vers}/${APP}-linux-amd64 ${BDIR}/${APP}
    rm -rf /tmp/${APP}_${vers} /tmp/${FN}
}

# download new
if [ -z $(which ${APP}) ]; then
  download new
else
  APPBIN=$(which ${APP})
  APPVER=$(${APPBIN} --version | grep -i ^${APP} | awk '{print $3}')
  [ "${APPVER}" = "$(echo $vers | sed 's/^v//')" ] && echo "${APP} version is current" || download ${vers}
fi
