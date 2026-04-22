APP="zig"
vers=$(wget -qO- https://ziglang.org/download/index.json | jq 'to_entries | map(select(.key !="master")) | .[] | .key' | tr -d '"' | sort -V | uniq | tail -1)
qstring=".\"${vers}\".\"x86_64-linux\".\"tarball\""
DL=$(wget -qO- https://ziglang.org/download/index.json | jq "${qstring}" | tr -d '"')
FN=$(basename "${DL}")

IDIR=/usr/local/lib
BDIR=/usr/local/bin

download() {
    echo "download $1 version"
    echo "installing $vers"

    local tmp_dir
    tmp_dir=$(gup_mktemp_dir)
    trap 'rm -rf "${tmp_dir}"' RETURN

    gup_download "${DL}" "${tmp_dir}/${FN}"
    sudo rm -f "${BDIR}/zig"
    sudo rm -rf "${IDIR}/zig"
    sudo mkdir -p "${IDIR}/zig"
    sudo tar axf "${tmp_dir}/${FN}" -C "${IDIR}/zig" --strip-components=1
    sudo ln -sf "${IDIR}/zig/zig" "${BDIR}/zig"
}

if [ -z "$(command -v "${APP}")" ]; then
    download new
else
    APPVER=$($(command -v "${APP}") version 2>&1)
    if [ "${APPVER}" = "${vers}" ]; then
        echo "${APP} version is current"
    else
        download "${vers}"
    fi
fi
