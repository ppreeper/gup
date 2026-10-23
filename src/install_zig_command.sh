set -eu

APP="zig"
IDIR=/usr/local/lib
BDIR=/usr/local/bin

zig_json=$(wget -qO- https://ziglang.org/download/index.json)
vers=$(printf '%s\n' "${zig_json}" | jq 'to_entries | map(select(.key !="master")) | .[] | .key' | tr -d '"' | sort -V | uniq | tail -1)
qstring=".\"${vers}\".\"x86_64-linux\".\"tarball\""
DL=$(printf '%s\n' "${zig_json}" | jq -r "${qstring}")
FN=$(basename "${DL}")

download() {
    echo "download $1 version"
    echo "installing $vers"

    tmp_dir=$(gup_mktemp_dir)
    trap '[ -z "${tmp_dir:-}" ] || rm -rf "${tmp_dir}"' EXIT

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
