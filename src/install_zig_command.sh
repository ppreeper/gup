APP="zig"
REPO="ziglang/zig"
RURL="https://api.github.com/repos/${REPO}/releases/latest"
vers=$(wget -qO- "${RURL}" | jq .tag_name | tr -d '"' | tr -d 'v')

DLREPO="https://ziglang.org/download"
FN="zig-x86_64-linux-$vers.tar.xz"
DL="${DLREPO}/$vers/${FN}"

IDIR=/usr/local/lib
BDIR=/usr/local/bin

function download(){
    echo "download $1 version"
    echo "installing $vers"
    rm -f /tmp/"${FN}"
    wget -qc "${DL}" -O /tmp/"${FN}"
    sudo rm -f "${BDIR}"/zig
    sudo rm -rf "${IDIR}"/zig
    sudo mkdir -p "${IDIR}"/zig
    sudo tar axf /tmp/"${FN}" -C "${IDIR}"/zig  --strip-components=1
    sudo ln -sf "${IDIR}"/zig/zig "${BDIR}"/zig
    rm -f /tmp/"${FN}"
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
