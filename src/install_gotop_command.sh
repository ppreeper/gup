APP="gotop"
REPO="https://github.com/xxxserxxx/gotop"
vers=$(git ls-remote --tags ${REPO} | grep "refs/tags.*[0-9]$" | awk '{print $2}' | sed 's/refs\/tags\///' | sort -V | uniq | tail -1)

USERIDNUMBER=$(grep $(whoami) /etc/passwd | awk -F":" '{print $3}')
if [ ${USERIDNUMBER} == 0 ]; then
  BDIR="/usr/local/bin"
else
  BDIR="${HOME}/.local/bin"
fi

function download() {
    echo "download $1 version"
    echo "installing ${vers}"
    FN=${APP}_${vers}_linux_amd64.tgz
    rm -f /tmp/${FN}
    wget -qc ${REPO}/releases/download/${vers}/${FN} -O /tmp/${FN}
    rm -f ${BDIR}/${APP}
    tar axf /tmp/${FN} -C ${BDIR}
    rm -f /tmp/${FN}
}

if [ -z $(which ${APP}) ]; then
    download new
else
    APPBIN=$(which ${APP})
    APPVER=$(${APPBIN} --version 2>&1 | grep ^${APP} | awk '{print $2}')
    [ "${APPVER}" = "${vers}" ] && echo "${APP} version is current" || download ${vers}
fi