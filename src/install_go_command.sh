set -eu

APP="go"
REPO="https://go.googlesource.com/go"
DLREPO="https://dl.google.com/go"
IDIR=/usr/local/lib
BDIR=/usr/local/bin

release=$(git ls-remote --heads "${REPO}" | grep release-branch.go1 | sed 's/.*go1/go1/' | sort -V | tail -1)
vers=$(git ls-remote --tags "${REPO}" | grep -E ${release}.[0-9]+ | sed 's/.*go1/go1/' | sort -V | tail -1)

download() {
    echo "download $1 version"
    echo "installing $vers"

    tmp_dir=$(gup_mktemp_dir)
    trap '[ -z "${tmp_dir:-}" ] || rm -rf "${tmp_dir}"' EXIT

    FN="${vers}.linux-amd64.tar.gz"
    gup_download "${DLREPO}/${FN}" "${tmp_dir}/${FN}"
    tar axf "${tmp_dir}/${FN}" -C "${tmp_dir}"
    sudo rm -rf "${IDIR}/go"
    sudo mkdir -p "${IDIR}"
    sudo mv "${tmp_dir}/go" "${IDIR}/go"
    sudo find "${IDIR}/go/bin" -type f |
    while IFS= read -r file; do
        sudo ln -sf "$file" "${BDIR}/$(basename "$file")"
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
