set -euo pipefail

APP="zig"
IDIR=/usr/local/lib
BDIR=/usr/local/bin

_gup_require_root "${APP}"

zig_json=$(wget -qO- https://ziglang.org/download/index.json)
vers=$(echo "${zig_json}" | jq 'to_entries | map(select(.key !="master")) | .[] | .key' | tr -d '"' | sort -V | uniq | tail -1)
qstring=".\"${vers}\".\"x86_64-linux\".\"tarball\""
DL=$(echo "${zig_json}" | jq -r "${qstring}")
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
