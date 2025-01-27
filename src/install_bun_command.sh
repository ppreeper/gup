APP="bun"
REPO="https://github.com/oven-sh/bun"
vers=$(git ls-remote --tags ${REPO} | grep "refs/tags/bun-.*[0-9]$" | grep -v -e "build" -e "alpha" -e "beta" | awk '{print $2}' | sed 's/refs\/tags\///g' | sort -V | uniq | tail -1)

if [ $(id -u) == 0 ]; then
  BDIR="/usr/local/bin"
else
  BDIR="${HOME}/.bun/bin"
fi

platform=$(uname -ms)
target=""
case $platform in
'Darwin x86_64')
    target=darwin-x64
    ;;
'Darwin arm64')
    target=darwin-aarch64
    ;;
'Linux aarch64' | 'Linux arm64')
    target=linux-aarch64
    ;;
'MINGW64'*)
    target=windows-x64
    ;;
'Linux x86_64' | *)
    target=linux-x64
    ;;
esac

# If AVX2 isn't supported, use the -baseline build
case "$target" in
'darwin-x64'*)
    if [[ $(sysctl -a | grep machdep.cpu | grep AVX2) == '' ]]; then
        target="$target-baseline"
    fi
    ;;
'linux-x64'*)
    # If AVX2 isn't supported, use the -baseline build
    if [[ $(cat /proc/cpuinfo | grep avx2) = '' ]]; then
        target="$target-baseline"
    fi
    ;;
esac

setup() {
  mkdir -p ${BDIR}
  grep "export BUN_INSTALL" ${HOME}/.bashrc > /dev/null || echo "export BUN_INSTALL=${BDIR}" >> ${HOME}/.bashrc
  grep "export PATH=\$BUN_INSTALL/bin:\$PATH" ~/.bashrc > /dev/null || echo "export PATH=\$BUN_INSTALL/bin:\$PATH" >> ${HOME}/.bashrc
}

download() {
  echo "download $1 version"
  echo "installing ${vers}"
  setup
  FN=${APP}-${target}.zip
  rm -rf /tmp/${APP}-${target}
  rm -f /tmp/${FN}
  wget -qc ${REPO}/releases/download/${vers}/${FN} -O /tmp/${FN}
  unzip /tmp/${FN} -d /tmp/${APP}-${target}
  install /tmp/${APP}-${target}/${APP}-${target}/${APP} ${BDIR}/${APP}
  rm -rf /tmp/${APP}-${target}
  rm -f /tmp/${FN}
}


if [ -z $(which ${APP}) ]; then
  download new
else
  APPBIN=$(which ${APP})
  APPVER=$(${APPBIN} --version)
  GITVER=$(echo $vers | sed 's/^bun-v//')
  [ "${APPVER}" = "${GITVER}" ] && echo "${APP} version is current" || download ${vers}
fi
