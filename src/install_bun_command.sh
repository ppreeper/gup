APP="bun"
REPO="oven-sh/bun"
RURL="https://api.github.com/repos/${REPO}/releases/latest"
vers=$(wget -qO- "${RURL}" | jq .tag_name | tr -d '"' | tr -d 'v')
DL=$(wget -qO- "${RURL}" | jq '.assets[] | select(.name | contains ("linux-x64.zip")) | .browser_download_url' | tr -d '"')
FN=$(wget -qO- "${RURL}" | jq '.assets[] | select(.name | contains ("linux-x64.zip")) | .name' | tr -d '"')

BDIR="${HOME}/.bun"
target="linux-x64"

download() {
    echo "download $1 version"
    echo "installing ${vers}"

    if [ "$(id -u)" == 0 ]; then
        BDIR="/usr/local/bun"
        sudo mkdir -p "${BDIR}"
        echo "BUN_INSTALL=${BDIR}" | sudo tee -a /etc/environment
        grep "export BUN_INSTALL" /etc/profile >/dev/null || echo "export BUN_INSTALL=${BDIR}" | sudo tee -a /etc/profile
        grep 'export PATH=$BUN_INSTALL/bin:$PATH' /etc/profile >/dev/null || echo 'export PATH=$BUN_INSTALL/bin:$PATH' | sudo tee -a /etc/profile
    else
        BDIR="${HOME}/.bun"
        mkdir -p "${BDIR}"
        echo "BUN_INSTALL=${BDIR}" >>${HOME}/.bashrc
        grep "export BUN_INSTALL" ${HOME}/.bashrc >/dev/null || echo "export BUN_INSTALL=${BDIR}" >>${HOME}/.bashrc
        grep 'export PATH=$BUN_INSTALL/bin:$PATH' ~/.bashrc >/dev/null || echo 'export PATH=$BUN_INSTALL/bin:$PATH' >>${HOME}/.bashrc
    fi

    rm -rf /tmp/"${APP}-${target}"
    rm -f /tmp/"${FN}"
    wget -qc "${DL}" -O /tmp/"${FN}"
    unzip /tmp/"${FN}" -d /tmp
    install /tmp/"${APP}-${target}"/"${APP}" "${BDIR}"/bin/"${APP}"
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
