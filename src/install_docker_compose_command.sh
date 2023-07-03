echo "docker-compose"
APP="docker-compose"
REPO="https://github.com/docker/compose"
vers=$(git ls-remote --tags ${REPO} | grep "refs/tags/v.*[0-9]$" | grep -v -e rc -e alpha -e beta | awk '{print $2}' | sed 's/refs\/tags\///' | sort -V | uniq | tail -1)

BDIR="/usr/local/bin"
BDIR="${HOME}/.local/bin"

OS=$(uname -s)
ARCH=$(uname -m)

download() {
    echo "download $1 version"
    echo "Installing ${vers}"
    echo sudo wget -qc "${REPO}/releases/download/${vers}/${APP}-${OS}-${ARCH}" -O ${BDIR}/${APP}
    echo sudo chmod +x ${BDIR}/${APP}
}

if [ -z "$(which ${APP})" ]; then
    download new
else
  APPBIN=$(which ${APP})
  APPVER=$(${APPBIN} version 2>&1 | grep ^Docker | awk '{print $4}')
  [ "${APPVER}" = "${vers}" ] && echo "${APP} version is current" || download ${vers}
fi
