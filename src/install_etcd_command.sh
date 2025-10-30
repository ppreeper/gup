APP="etcd"
REPO="etcd-io/etcd"
RURL="https://api.github.com/repos/${REPO}/releases/latest"
vers=$(wget -qO- "${RURL}" | jq .tag_name | tr -d '"' | tr -d 'v')

BDIR="/usr/local/bin"

download() {
    echo "download $1 version"
    echo "installing ${vers}"
    DL=$(wget -qO- "${RURL}" | jq '.assets[] | select(.name | contains ("linux-amd64")) | .browser_download_url' | tr -d '"')
    FN=$(wget -qO- "${RURL}" | jq '.assets[] | select(.name | contains ("linux-amd64")) | .name' | tr -d '"')
    rm -rf /tmp/etcd
    wget -qc "${DL}" -O "/tmp/${FN}"
    mkdir -p /tmp/etcd
    tar -axf "/tmp/${FN}" -C /tmp/etcd --strip-components=1
    sudo install /tmp/etcd/etcd* "${BDIR}"/.
    rm -rf /tmp/etcd
    rm -f "/tmp/${FN}"
}

if [ -z "$(which ${APP})" ]; then
    download new
else
    APPVER=$($(which ${APP}) --version 2>&1 | grep "etcd.*Version" | awk '{print $3}' | sed 's/^v//')
    if [ "${APPVER}" = "${vers}" ]; then
        echo "${APP} version is current"
    else
        download "${vers}"
    fi
fi
