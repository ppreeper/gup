APP="postgres_exporter"
REPO="https://github.com/prometheus-community/postgres_exporter"
vers=$(git ls-remote --tags ${REPO} | grep "refs/tags.*[0-9]$" | grep -v -e rc -e alpha -e beta | awk '{print $2}' | sed 's/refs\/tags\///' | sort -V | uniq | tail -1)

USERIDNUMBER=$(grep $(whoami) /etc/passwd | awk -F":" '{print $3}')
if [ ${USERIDNUMBER} == 0 ]; then
  BDIR="/usr/local/bin"
else
  BDIR="${HOME}/.local/bin"
fi

download() {
    echo "download $1 version"
    echo "installing ${vers}"
    fn="${APP}-$(echo $vers | sed 's/^v//').linux-amd64.tar.gz"
    rm -f /tmp/${fn}
    wget -qc ${REPO}/releases/download/${vers}/${fn} -O /tmp/${fn}
    rm -f ${BDIR}/${APP}
    mkdir -p /tmp/${APP}_${vers}
    tar axf /tmp/${fn} -C /tmp/${APP}_${vers} --strip-components=1
    install /tmp/${APP}_${vers}/${APP} ${BDIR}/${APP}
    rm -rf /tmp/${APP}_${vers} /tmp/${fn}
}

if [ -z "$(which ${APP})" ]; then
  download new
else
  APPBIN=$(which ${APP})
  APPVER=$(${APPBIN} --version 2>&1 |grep -i ^${APP} | awk '{print $3}')
  [ "${APPVER}" = "$(echo $vers | sed 's/^v//')" ] && echo "${APP} version is current" || download ${vers}
fi