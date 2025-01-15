APP="zls"
REPO="https://github.com/ziglang/zig"
DLREPO="https://builds.zigtools.org"
vers=$(git ls-remote --tags ${REPO} | grep "refs/tags/.*[0-9]$" | grep -v -e rc -e alpha -e beta | awk '{print $2}' | sed 's/refs\/tags\///' | sort -V | uniq | tail -1)

IDIR=/usr/local/lib
BDIR=/usr/local/bin

function download(){
    echo "download $1 version"
    echo "installing $vers"
    FN=zls-linux-x86_64-$vers.tar.xz
    rm -f /tmp/${FN}
    wget -qc ${DLREPO}/${FN} -O /tmp/${FN}
    sudo rm -f ${BDIR}/zls
    sudo tar axf /tmp/${FN} -C ${BDIR} zls
    rm -f /tmp/${FN}
}

if [ -z $(which ${APP}) ]; then
    download new
else
    APPBIN=$(which ${APP})
    APPVER=$(${APPBIN} --version)
    [ "${APPVER}" = "${vers}" ] && echo "${APP} version is current" || download ${vers}
fi

