APP="blackbox_exporter"
REPO="https://github.com/prometheus/${APP}"
vers=$(git ls-remote --tags ${REPO} | grep "refs/tags.*[0-9]$" | grep -v -e "rc" -e "alpha" -e "beta" | awk '{print $2}' | sed 's/refs\/tags\///g' | sort -V | uniq | tail -1)

# > wget -qO- https://api.github.com/repos/prometheus/blackbox_exporter/releases/latest | jq .tag_name
# "v0.27.0"

# wget -qO- https://api.github.com/repos/prometheus/blackbox_exporter/releases/latest | jq '.assets[] | select(.name | contains ("linux-amd64"))'

# > wget -qO- https://api.github.com/repos/prometheus/blackbox_exporter/releases/latest | jq '.assets[] | select(.name | contains ("linux-amd64")) | .browser_download_url'
# "https://github.com/prometheus/blackbox_exporter/releases/download/v0.27.0/blackbox_exporter-0.27.0.linux-amd64.tar.gz"



BDIR=/usr/local/bin
BDIR=${HOME}/.local/bin
IDIR=${HOME}/.local/$APP

function download() {
    echo "download $1 version"
    echo "installing ${vers}"
    V=$(echo $vers | sed 's/^v//')
    FN=${APP}-${V}.linux-amd64.tar.gz
    rm -f /tmp/${FN}
    wget -qc ${REPO}/releases/download/${vers}/${FN} -O /tmp/${FN}
    mkdir -p ${IDIR}
    rm -rf ${IDIR}/*
    tar -zxf /tmp/${FN} --strip-components=1 -C ${IDIR}
    ln -sf ${IDIR}/$APP ${BDIR}/$APP
    rm -f /tmp/${FN}
}

if [ -z $(which ${APP}) ]; then
    download new
else
    APPBIN=$(which ${APP})
    APPVER=$(${APPBIN} --version 2>&1 | grep -i "^${APP}" | awk '{print $2}')
    [ "${APPVER}" = "${vers}" ] && echo "${APP} version is current" || download ${vers}
fi