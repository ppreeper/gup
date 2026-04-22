APP="fj"
DL="https://codeberg.org/forgejo-contrib/forgejo-cli/releases/download/latest/forgejo-cli-linux.tar.gz"
FN="forgejo-cli-linux.tar.gz"

download() {
    echo "download $1 version"

    local tmp_dir
    tmp_dir=$(gup_mktemp_dir)
    trap 'rm -rf "${tmp_dir}"' RETURN

    gup_download "${DL}" "${tmp_dir}/${FN}"
    tar -axf "${tmp_dir}/${FN}" -C "${tmp_dir}"

    if [ "$(id -u)" = 0 ]; then
        BDIR="/usr/local/bin"
    else
        BDIR="${HOME}/.local/bin"
        mkdir -p "${BDIR}"
    fi

    install -Dm755 "${tmp_dir}/${APP}" "${BDIR}/${APP}"
}

download new
