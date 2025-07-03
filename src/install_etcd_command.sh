APP="etcd"
REPO="https://github.com/etcd-io/etcd"
DURL="https://github.com/etcd-io/etcd/releases/download"

vers=$(git ls-remote --tags ${REPO} | grep "refs/tags.*[0-9]$" | grep -v -e "rc" -e "alpha" -e "beta" | awk '{print $2}' | sed 's/refs\/tags\///g' | sort -V | uniq | tail -1)

BDIR="/usr/local/bin"

download() {
    echo "download $1 version"
    echo "installing ${vers}"
    FN="${APP}-${vers}-linux-amd64.tar.gz"
    rm -rf /tmp/etcd
    wget -qc "${DURL}/${vers}/${FN}" -O "/tmp/${FN}"
    mkdir -p /tmp/etcd
    tar -axf "/tmp/${FN}" -C /tmp/etcd --strip-components=1
    sudo mv /tmp/etcd/etcd* "${BDIR}"/.
    sudo chmod +x "${BDIR}"/etcd*
    rm -rf /tmp/etcd
    rm -f "/tmp/${FN}"
}

if [ -z "$(which ${APP})" ]; then
    download new
else
    APPVER=$(etcd --version | grep "etcd.*Version" | awk '{print $3}' | sed 's/^v//')
    [ "${APPVER}" = "${vers}" ] && echo "${APP} version is current" || download "${vers}"
fi
