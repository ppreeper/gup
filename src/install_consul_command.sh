CMD="consul"
REPO="https://github.com/hashicorp/consul"
DURL="https://releases.hashicorp.com/consul"

vers=$(git ls-remote --tags ${REPO} | grep "refs/tags.*[0-9]$" | grep -v -e "rc" -e "alpha" -e "beta" | awk '{print $2}' | sed 's/refs\/tags\///g' | sort -V | uniq | tail -1)

# BDIR="/usr/local/bin"
BDIR="${HOME}/.local/bin"

download() {
  echo "download $1 version"
  echo "installing ${vers}"
  vers=$(echo $vers | sed 's/^v//')
  FN=${CMD}_${vers}_linux_amd64.zip
  rm -f /tmp/${FN}
  wget -qc ${DURL}/${vers}/${FN} -O /tmp/${FN}
  unzip /tmp/${FN} -d /tmp/${CMD}_${vers}
  install /tmp/${CMD}_${vers}/${CMD} ${BDIR}/${CMD}
  rm -rf /tmp/${CMD}_${vers}
  rm -f /tmp/${FN}
}


if [ -z $(which ${CMD}) ]; then
  download new
else
  APP=$(which ${CMD})
  APPVER=$(${APP} version | grep -i ^${CMD} | awk '{print $2}')
  [ "${APPVER}" = "${vers}" ] && echo "${CMD} version is current" || download new
fi
