APP="traefik"
REPO="https://github.com/traefik/traefik"
vers=$(git ls-remote --tags ${REPO} | grep "refs/tags.*[0-9]$" | grep -v -e "rc" -e "alpha" -e "beta" | awk '{print $2}' | sed 's/refs\/tags\///' | sort -V | uniq | tail -1)

USERIDNUMBER=$(grep $(whoami) /etc/passwd | awk -F":" '{print $3}')
if [ ${USERIDNUMBER} == 0 ]; then
  BDIR="/usr/local/bin"
else
  BDIR="${HOME}/.local/bin"
fi

function download(){
    echo "download $1 version"
    echo "installing ${vers}"
    V=$(echo $vers | sed 's/^v//')
    FN=${APP}_${vers}_linux_amd64.tar.gz
    rm -f /tmp/${FN}
    wget -qc ${REPO}/releases/download/${vers}/${FN} -O /tmp/${FN}
    mkdir -p /tmp/${APP}_${vers}
    tar axf /tmp/${FN} -C /tmp/${APP}_${vers}
    install /tmp/${APP}_${vers}/${APP} ${BDIR}/${APP}
    rm -rf /tmp/${APP}_${vers} /tmp/${FN}
}

if [ -z $(which ${APP}) ]; then
    download new
else
    APPBIN=$(which ${APP})
    APPVER=$(${APPBIN} version | grep ^Version | awk '{print $2}')
    [ "${APPVER}" = "$(echo $vers | sed 's/^v//')" ] && echo "${APP} version is current" || download ${vers}
fi