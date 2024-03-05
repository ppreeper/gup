APP="tailwindcss"
REPO="https://github.com/tailwindlabs/tailwindcss"
vers=$(git ls-remote --tags ${REPO} | grep "refs/tags.*[0-9]$" | awk '{print $2}' | sed 's/refs\/tags\///' | sort -V | uniq | tail -1)

if [ $(id -u) == 0 ]; then
  BDIR="/usr/local/bin"
else
  BDIR="${HOME}/.local/bin"
fi

function download() {
    echo "download $1 version"
    echo "installing ${vers}"
    FN=${APP}-linux-x64
    wget -qc ${REPO}/releases/download/${vers}/${FN} -O ${BDIR}/${APP}
    chmod +x ${BDIR}/${APP}
}

if [ -z $(which ${APP}) ]; then
    download new
else
    APPBIN=$(which ${APP})
    APPVER=$(${APPBIN} --help 2>&1 | grep ^${APP} | awk '{print $2}')
    [ "${APPVER}" = "${vers}" ] && echo "${APP} version is current" || download ${vers}
fi