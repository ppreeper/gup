APP="gitea"
REPO="https://github.com/go-gitea/gitea"
DLREPO="https://dl.gitea.com/gitea"
vers=$(git ls-remote --tags ${REPO} | awk '{print $2}' | awk -F'/' '{print $NF}' | grep -v -e "rc" -e "dev" | grep '[0-9]$' | sed 's/^v//' | sort -V | uniq | tail -1)

if [ "$(id -u)" == 0 ]; then
  BDIR="/usr/local/bin"
else
  BDIR="${HOME}/.local/bin"
fi

function download() {
    echo "download $1 version"
    echo "installing ${vers}"
    mkdir -p ${BDIR}
    FN=${APP}-${vers}-linux-amd64
    wget -qO ${BDIR}/${APP} ${DLREPO}/${vers}/${FN}
    chmod +x ${BDIR}/${APP}
}

if [ -z "$(which ${APP})" ]; then
    download new
else
  APPBIN=$(which ${APP})
  APPVER=$(${APPBIN} --version | awk '{print $3}')
  [ "${APPVER}" = "${vers}" ] && echo "${APP} version is current" || download "${vers}"
fi