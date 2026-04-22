APP="go"
REPO="https://go.googlesource.com/go"
DLREPO="https://dl.google.com/go"
vers=$(git ls-remote --tags "${REPO}" | grep -E 'refs/tags/go[0-9]+\.[0-9]+(\.[0-9]+)?$' | awk '{print $2}' | sed 's/refs\/tags\///' | sort -V | uniq | tail -1)

IDIR=/usr/local/lib
BDIR=/usr/local/bin

download() {
    echo "download $1 version"
    echo "installing $vers"

    local tmp_dir
    tmp_dir=$(gup_mktemp_dir)
    trap 'rm -rf "${tmp_dir}"' RETURN

    FN="${vers}.linux-amd64.tar.gz"
    gup_download "${DLREPO}/${FN}" "${tmp_dir}/${FN}"
    sudo rm -rf "${IDIR}/go"
    sudo tar axf "${tmp_dir}/${FN}" -C "${IDIR}"
    find "${IDIR}/go/bin" -type f -exec sh -c 'sudo ln -sf "$1" "${BDIR}/$(basename "$1")"' _ {} +
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
