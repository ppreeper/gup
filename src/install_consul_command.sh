APP="consul"
REPO="https://github.com/hashicorp/consul"
DURL="https://releases.hashicorp.com/consul"

vers=$(git ls-remote --tags ${REPO} | grep "refs/tags.*[0-9]$" | grep -v -e "rc" -e "alpha" -e "beta" | awk '{print $2}' | sed 's/refs\/tags\///g' | sort -V | uniq | tail -1)

# BDIR="/usr/local/bin"
BDIR="${HOME}/.local/bin"

download() {
  echo "download $1 version"
  echo "installing ${vers}"
  vers=$(echo $vers | sed 's/^v//')
  FN=${APP}_${vers}_linux_amd64.zip
  rm -f /tmp/${FN}
  wget -qc ${DURL}/${vers}/${FN} -O /tmp/${FN}
  unzip /tmp/${FN} -d /tmp/${APP}_${vers}
  install /tmp/${APP}_${vers}/${APP} ${BDIR}/${APP}
  rm -rf /tmp/${APP}_${vers}
  rm -f /tmp/${FN}
}


if [ -z $(which ${APP}) ]; then
  download new
else
  APPBIN=$(which ${APP})
  APPVER=$(${APPBIN} version | grep -i ^${APP} | awk '{print $2}')
  [ "${APPVER}" = "${vers}" ] && echo "${APP} version is current" || download ${vers}
fi
