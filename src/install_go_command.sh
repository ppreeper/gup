APP="go"
REPO="https://github.com/golang/go"
DLREPO="https://dl.google.com/go"
vers=$(git ls-remote --tags ${REPO} | grep -E 'refs/tags/go[0-9]+\.[0-9]+(\.[0-9]+)?$' | awk '{print $2}' | sed 's/refs\/tags\///' | sort -V | uniq | tail -1)

IDIR=/usr/local/lib
BDIR=/usr/local/bin

function download(){
    echo "download $1 version"
    echo "installing $vers"
    FN=$vers.linux-amd64.tar.gz
    rm -f /tmp/"${FN}"
    wget -qc "${DLREPO}/${FN}" -O /tmp/"${FN}"
    sudo ls ${IDIR}/go/bin 2>/dev/null | sudo xargs -I {} rm -f ${BDIR}/{}
    sudo rm -rf ${IDIR}/go
    sudo tar axf /tmp/"${FN}" -C ${IDIR}
    sudo ls ${IDIR}/go/bin | sudo xargs -I {} ln -sf ${IDIR}/go/bin/{} ${BDIR}/{}
    rm -f /tmp/"${FN}"
}

if [ -z "$(which ${APP})" ]; then
    download new
else
    APPVER=$($(which ${APP}) version 2>&1 | awk '{print $3}')
    if [ "${APPVER}" = "${vers}" ]; then
        echo "${APP} version is current"
    else
        download "${vers}"
    fi
fi

