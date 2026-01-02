APP="b2"
DL="https://github.com/Backblaze/B2_Command_Line_Tool/releases/latest/download/b2-linux"

download() {
    echo "download $1 version"
    rm -f /tmp/"${APP}"
    wget -qc "${DL}" -O /tmp/"${APP}"
    if [ "$(id -u)" == 0 ]; then
        BDIR="/usr/local/bin"
        sudo rm -f "${BDIR}"/"${APP}"
        sudo install /tmp/"${APP}" "${BDIR}"/"${APP}"
    else
        BDIR="${HOME}/.local/bin"
        rm -f "${BDIR}"/"${APP}"
        install /tmp/"${APP}" "${BDIR}"/"${APP}"
    fi
    rm -f /tmp/"${APP}"
}

download "$APP"
