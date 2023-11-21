APP="caddy"
REPO="https://github.com/caddyserver/caddy"
vers=$(git ls-remote --tags ${REPO} | grep "refs/tags.*[0-9]$" | grep -v -e rc -e alpha -e beta | awk '{print $2}' | sed 's/refs\/tags\///' | sort -V | uniq | tail -1)

if [ $(id -u) == 0 ]; then
  BDIR="/usr/local/bin"
else
  BDIR="${HOME}/.local/bin"
fi

download() {
    echo "download $1 version"
    echo "installing ${vers}"
    V=$(echo $vers | sed 's/v//')
    FN=${APP}_${V}_linux_amd64.tar.gz
    rm -f /tmp/${FN}
    wget -qc ${REPO}/releases/download/${vers}/${FN} -O /tmp/${FN}
    rm -f ${BDIR}/${APP}
    mkdir -p /tmp/${APP}_${V}
    tar axf /tmp/${FN} -C /tmp/${APP}_${V}
    install /tmp/${APP}_${V}/${APP} ${BDIR}
    rm -rf /tmp/${FN} /tmp/${APP}_${V}
}

if [ -z "$(which ${APP})" ]; then
    download new
else
  APPBIN=$(which ${APP})
  APPVER=$(${APPBIN} version 2>&1 | grep -i "^v" | awk '{print $1}')
  [ "${APPVER}" = "${vers}" ] && echo "${APP} version is current" || download ${vers}
fi
