APP="zls"
REPO="zigtools/zls"
RURL="https://api.github.com/repos/${REPO}/releases/latest"
vers=$(wget -qO- "${RURL}" | jq .tag_name | tr -d '"' | tr -d 'v')
DL=$(wget -qO- "${RURL}" | jq '.assets[] | select(.name | (contains("minisig") | not) and contains("x86_64-linux")) | .browser_download_url' | tr -d '"')
FN=$(wget -qO- "${RURL}" | jq '.assets[] | select(.name | (contains("minisig") | not) and contains("x86_64-linux")) | .name' | tr -d '"')

function download(){
    echo "download $1 version"
    echo "installing $vers"
    rm -rf /tmp/"${FN}" /tmp/"${APP}_${vers}"
    wget -qc "${DL}" -O /tmp/"${FN}"
    mkdir -p /tmp/"${APP}_${vers}"
    tar axf /tmp/"${FN}" -C /tmp/"${APP}_${vers}"
    BDIR=/usr/local/bin
    sudo rm -f "${BDIR}"/zls
    sudo install /tmp/"${APP}_${vers}"/zls "${BDIR}"/zls
    rm -rf /tmp/"${FN}" /tmp/"${APP}_${vers}"
}

if [ -z "$(which ${APP})" ]; then
    download new
else
    APPVER=$($(which ${APP}) version 2>&1)
    if [ "${APPVER}" = "${vers}" ]; then
        echo "${APP} version is current"
    else
        download "${vers}"
    fi
fi
