APP="zig"
REPO="https://github.com/ziglang/zig"
DLREPO="https://ziglang.org/download"
vers=$(git ls-remote --tags ${REPO} | grep "refs/tags/.*[0-9]$" | grep -v -e rc -e alpha -e beta | awk '{print $2}' | sed 's/refs\/tags\///' | sort -V | uniq | tail -1)

IDIR=/usr/local/lib
BDIR=/usr/local/bin

function download(){
    echo "download $1 version"
    echo "installing $vers"
    FN=zig-linux-x86_64-$vers.tar.xz
    FN=zig-x86_64-linux-$vers.tar.xz
    rm -f /tmp/${FN}
    wget -qc ${DLREPO}/$vers/${FN} -O /tmp/${FN}
    sudo rm -f ${BDIR}/zig
    sudo rm -rf ${IDIR}/zig
    sudo mkdir -p ${IDIR}/zig
    sudo tar axf /tmp/${FN} --strip-components=1 -C ${IDIR}/zig
    sudo ln -sf ${IDIR}/zig/zig ${BDIR}/zig
    rm -f /tmp/${FN}
}

if [ -z $(which ${APP}) ]; then
    download new
else
    APPBIN=$(which ${APP})
    APPVER=$(${APPBIN} version)
    [ "${APPVER}" = "${vers}" ] && echo "${APP} version is current" || download ${vers}
fi
