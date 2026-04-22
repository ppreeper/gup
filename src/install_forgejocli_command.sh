APP="fj"
DL="https://codeberg.org/forgejo-contrib/forgejo-cli/releases/download/latest/forgejo-cli-linux.tar.gz"
FN="forgejo-cli-linux.tar.gz"

BDIR=/usr/local/bin

function download() {
    echo "download $1 version"

    local tmp_dir
    tmp_dir=$(gup_mktemp_dir)
    trap 'rm -rf "${tmp_dir}"' RETURN

    wget -qc "${DL}" -O "${tmp_dir}/${FN}"
    sudo tar -axf "${tmp_dir}/${FN}" -C "${tmp_dir}"
    sudo rm -rf "${BDIR}/${APP}"
    sudo install -Dm755 "${tmp_dir}/${APP}" "${BDIR}/${APP}"
}
