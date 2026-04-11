APP="b2"
DL="https://github.com/Backblaze/B2_Command_Line_Tool/releases/latest/download/b2-linux"

download() {
    local tmpdir out bdir
    tmpdir=$(mktemp -d) || { printf 'failed to create tempdir\n' >&2; return 1; }
    trap 'rm -rf "${tmpdir}"' RETURN
    out="${tmpdir}/${APP}"

    printf "download %s ...\n" "${APP}"
    gup_download "${DL}" "${out}" || { printf 'download failed\n' >&2; return 1; }

    chmod +x "${out}"

    if (( EUID == 0 )); then
        bdir="/usr/local/bin"
        rm -f "${bdir}"/"${APP}"
        install -m 0755 "${out}" "${bdir}"/"${APP}"
    else
        bdir="${HOME}/.local/bin"
        mkdir -p "${bdir}"
        rm -f "${bdir}"/"${APP}"
        install -m 0755 "${out}" "${bdir}"/"${APP}"
    fi
}

download "${APP}"
