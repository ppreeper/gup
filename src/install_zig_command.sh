APP="zig"
IDIR=/usr/local/lib
BDIR=/usr/local/bin

if [ "$(id -u)" -ne 0 ]; then
    echo "Error: ${APP} requires root privileges for system-wide install" >&2
    exit 1
fi

vers=$(wget -qO- https://ziglang.org/download/index.json | jq 'to_entries | map(select(.key !="master")) | .[] | .key' | tr -d '"' | sort -V | uniq | tail -1)
qstring=".\"${vers}\".\"x86_64-linux\".\"tarball\""
DL=$(wget -qO- https://ziglang.org/download/index.json | jq "${qstring}" | tr -d '"')
FN=$(basename "${DL}")

download() {
    echo "download $1 version"
    echo "installing $vers"

    local tmp_dir
    tmp_dir=$(gup_mktemp_dir)
    trap 'rm -rf "${tmp_dir}"' RETURN

    gup_download "${DL}" "${tmp_dir}/${FN}"
    rm -f "${BDIR}/zig"
    rm -rf "${IDIR}/zig"
    mkdir -p "${IDIR}/zig"
    tar axf "${tmp_dir}/${FN}" -C "${IDIR}/zig" --strip-components=1
    ln -sf "${IDIR}/zig/zig" "${BDIR}/zig"
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
