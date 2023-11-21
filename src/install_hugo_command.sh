APP="hugo"
REPO="https://github.com/gohugoio/hugo"
vers=$(git ls-remote --tags ${REPO} | grep "refs/tags.*[0-9]$" | awk '{print $2}' | sed 's/refs\/tags\///g' | sort -V | uniq | tail -1)

if [ $(id -u) == 0 ]; then
  BDIR="/usr/local/bin"
else
  BDIR="${HOME}/.local/bin"
fi

function download() {
    echo "download $1 version"
    echo "installing ${vers}"
    V=$(echo ${vers} | sed 's/^v//')
    FN=${APP}_extended_${V}_Linux-64bit.tar.gz
    wget -qc ${REPO}/releases/download/${vers}/${FN} -O /tmp/hugo.tar.gz
    tar -axf /tmp/hugo.tar.gz -C ${BDIR} hugo
    rm -f /tmp/hugo.tar.gz
}

if [ -z $(which ${APP}) ]; then
    download new
else
    APPBIN=$(which ${APP})
    APPVER=$(${APPBIN} version | awk '{print $2}' | awk -F'-' '{print $1}')
    [ "${APPVER}" = "${vers}" ] && echo "${APP} version is current" || download ${vers}
fi