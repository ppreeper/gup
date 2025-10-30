APP="zig"
vers=$(wget -qO- https://ziglang.org/download/index.json | jq 'to_entries | map(select(.key !="master")) | .[] | .key' | tr -d '"' | sort -V | uniq | tail -1)
qstring=".\"${vers}\".\"x86_64-linux\".\"tarball\""
DL=$(wget -qO- https://ziglang.org/download/index.json | jq "${qstring}" | tr -d '"')
FN=$(basename "${DL}")

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
