set -euo pipefail

APP="go"
REPO="https://go.googlesource.com/go"
DLREPO="https://dl.google.com/go"
IDIR=/usr/local/lib
BDIR=/usr/local/bin

_gup_require_root "${APP}"

vers=$(git ls-remote --tags "${REPO}" | grep -E 'refs/tags/go[0-9]+\.[0-9]+(\.[0-9]+)?$' | awk '{print $2}' | sed 's/refs\/tags\///' | sort -V | uniq | tail -1)

download() {
    echo "download $1 version"
    echo "installing $vers"

    local tmp_dir
    tmp_dir=$(gup_mktemp_dir)
    trap '[ -z "${tmp_dir:-}" ] || rm -rf "${tmp_dir}"' RETURN

    FN="${vers}.linux-amd64.tar.gz"
    gup_download "${DLREPO}/${FN}" "${tmp_dir}/${FN}"
    tar axf "${tmp_dir}/${FN}" -C "${tmp_dir}"
    rm -rf "${IDIR}/go"
    mkdir -p "${IDIR}"
    mv "${tmp_dir}/go" "${IDIR}/go"
    find "${IDIR}/go/bin" -type f -print0 |
    while IFS= read -r -d '' file; do
        ln -sf "$file" "${BDIR}/$(basename "$file")"
    done
}

if [ -z "$(command -v "${APP}")" ]; then
    download new
else
    APPVER=$($(command -v "${APP}") version 2>&1 | awk '{print $3}')
    if [ "${APPVER}" = "${vers}" ]; then
        echo "${APP} version is current"
    else
        download "${vers}"
    fi
fi
