CMD="wkhtmltopdf"
REPO="https://github.com/wkhtmltopdf/packaging"
vers=$(git ls-remote --tags ${REPO} | grep "refs/tags.*[0-9]$" | awk '{print $2}' | sed 's/refs\/tags\///' | sort -V | uniq | tail -1)

function download() {
    echo "download $1 version"
    echo "Installing ${vers}"
    VC=$(grep ^VERSION_CODENAME /etc/os-release | awk -F'=' '{print $2}')
    UC=$(grep ^UBUNTU_CODENAME /etc/os-release | awk -F'=' '{print $2}')
    CN=''
    [ -n "$UC" ] && CN=$UC || CN=$VC
    FN="wkhtmltox_${vers}.${CN}_amd64.deb"
    sudo rm -f /tmp/${FN}
    wget -qc ${REPO}/releases/download/${vers}/${FN} -O /tmp/${FN}
    sudo apt install /tmp/${FN}
    sudo rm -f /tmp/${FN}
}

if [ -z $(which ${CMD}) ]; then
    download new
else
    APP=$(which ${CMD})
    APPVER=$(${APP} --version | awk '{print $2}')
    echo $APPVER $vers
    [ "${APPVER}" = "${vers}" ] && echo "${CMD} version is current" || download new
fi