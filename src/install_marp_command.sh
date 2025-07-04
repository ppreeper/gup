APP="marp"
REPO="https://github.com/marp-team/marp-cli"
DURL="https://github.com/marp-team/marp-cli/releases/download"

vers=$(git ls-remote --tags ${REPO} | grep "refs/tags.*[0-9]$" | grep -v -e "rc" -e "alpha" -e "beta" | awk '{print $2}' | sed 's/refs\/tags\///g' | sort -V | uniq | tail -1)

BDIR="/usr/local/bin"

download() {
    echo "download $1 version"
    echo "installing ${vers}"
    FN="marp-cli-${vers}-linux.tar.gz"
    wget -qc "${DURL}/${vers}/${FN}" -O "/tmp/${FN}"
    sudo tar axf "/tmp/${FN}" -C "${BDIR}" "${APP}"
    sudo chmod +x "${BDIR}/${APP}"
    rm -f "/tmp/${FN}"
}

if [ -z "$(which ${APP})" ]; then
    download new
else
    APPVER=$(marp --version | grep marp-cli | awk '{print $2}')
    [ "${APPVER}" = "${vers}" ] && echo "${APP} version is current" || download "${vers}"
fi
