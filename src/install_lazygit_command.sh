APP="lazygit"
REPO="https://github.com/jesseduffield/lazygit"
vers=$(git ls-remote --tags ${REPO} | grep "refs/tags.*[0-9]$" | awk '{print $2}' | sed 's/refs\/tags\///' | sort -V | uniq | tail -1 | sed 's/^v//')

IDIR="${HOME}/.local/bin"

if [ $(id -u) == 0 ]; then
  IDIR="/usr/local/bin"
fi

function download() {
    echo "download $1 version"
    echo "installing ${vers}"
    mkdir -p ${IDIR}
    FN=lazygit_${vers}_Linux_x86_64.tar.gz
    rm -rf /tmp/lazygit /tmp/${FN}
    wget -qc ${REPO}/releases/download/v${vers}/${FN} -O /tmp/${FN}
    tar axf /tmp/${FN} lazygit
    install lazygit $IDIR
    rm -rf lazygit /tmp/${FN}
}


if [ -z $(which ${APP}) ]; then
    download new
else
  APPBIN=$(which ${APP})
  APPVER=$(${APPBIN} --version | awk '{print $6}' | sed 's/,//g' | awk -F'=' '{print $2}')
  [ "${APPVER}" = "${vers}" ] && echo "${APP} version is current" || download ${vers}
fi
