APP="uv"
REPO="https://github.com/astral-sh/uv"
vers=$(git ls-remote --tags ${REPO} | grep "refs/tags.*[0-9]$" | awk '{print $2}' | sed 's/refs\/tags\///' | grep -v "^v" | sort -V | uniq | tail -1)

BDIR=/usr/local/bin

function download() {
    echo "download $1 version"
    echo "installing ${vers}"
    FN=${APP}-x86_64-unknown-linux-gnu.tar.gz
    rm -f /tmp/${FN}
    wget -qc ${REPO}/releases/download/${vers}/${FN} -O /tmp/${FN}
    sudo tar -axf /tmp/${FN} --strip-components=1 -C ${BDIR}
    rm -f /tmp/${FN}
}

if [ -z $(which ${APP}) ]; then
    download new
else
    APPBIN=$(which ${APP})
    APPVER=$(${APPBIN} version | awk '{print $2}')
    [ "${APPVER}" = "${vers}" ] && echo "${APP} version is current" || download ${vers}
fi