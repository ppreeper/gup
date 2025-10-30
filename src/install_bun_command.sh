APP="bun"
REPO="oven-sh/bun"
RURL="https://api.github.com/repos/${REPO}/releases/latest"
vers=$(wget -qO- "${RURL}" | jq .tag_name | tr -d '"' | tr -d 'v')
DL=$(wget -qO- "${RURL}" | jq '.assets[] | select(.name | contains ("linux-x64.zip")) | .browser_download_url' | tr -d '"')
FN=$(wget -qO- "${RURL}" | jq '.assets[] | select(.name | contains ("linux-x64.zip")) | .name' | tr -d '"')

BDIR="${HOME}/.bun"

target="linux-x64"

# platform=$(uname -ms)
# target=""
# case $platform in
# 'Darwin x86_64')
#     target=darwin-x64
#     ;;
# 'Darwin arm64')
#     target=darwin-aarch64
#     ;;
# 'Linux aarch64' | 'Linux arm64')
#     target=linux-aarch64
#     ;;
# 'MINGW64'*)
#     target=windows-x64
#     ;;
# 'Linux x86_64' | *)
#     target=linux-x64
#     ;;
# esac

# If AVX2 isn't supported, use the -baseline build
# case "$target" in
# 'darwin-x64'*)
#     if [[ $(sysctl -a | grep machdep.cpu | grep AVX2) == '' ]]; then
#         target="$target-baseline"
#     fi
#     ;;
# 'linux-x64'*)
#     # If AVX2 isn't supported, use the -baseline build
#     if [[ $(cat /proc/cpuinfo | grep avx2) = '' ]]; then
#         target="$target-baseline"
#     fi
#     ;;
# esac

setup() {
    mkdir -p "${BDIR}"
    grep "export BUN_INSTALL" ${HOME}/.bashrc >/dev/null || echo "export BUN_INSTALL=${BDIR}" >>${HOME}/.bashrc
    grep 'export PATH=$BUN_INSTALL/bin:$PATH' ~/.bashrc >/dev/null || echo 'export PATH=$BUN_INSTALL/bin:$PATH' >>${HOME}/.bashrc
    echo "setup done"
}

download() {
    echo "download $1 version"
    echo "installing ${vers}"
    setup
    rm -rf /tmp/"${APP}-${target}"
    rm -f /tmp/"${FN}"
    wget -qc "${DL}" -O /tmp/"${FN}"
    unzip /tmp/"${FN}" -d /tmp/"${APP}-${target}"
    install /tmp/"${APP}-${target}"/"${APP}-${target}"/"${APP}" "${BDIR}"/bin/"${APP}"
    rm -rf /tmp/"${APP}-${target}"
    rm -f /tmp/"${FN}"
}

if [ -z "$(which ${APP})" ]; then
    download new
else
    APPVER=$($(which ${APP}) --version 2>&1)
    if [ "${APPVER}" = "${vers}" ]; then
        echo "${APP} version is current"
    else
        download "${vers}"
    fi
fi
