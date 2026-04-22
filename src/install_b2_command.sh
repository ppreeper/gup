set -euo pipefail

APP="b2"
DL="https://github.com/Backblaze/B2_Command_Line_Tool/releases/latest/download/b2-linux"

download() {
    echo "download ${APP} ..."

    local tmp_dir
    tmp_dir=$(gup_mktemp_dir)
    trap 'rm -rf "${tmp_dir}"' RETURN

    gup_download "${DL}" "${tmp_dir}/${APP}"
    _gup_install_binary "${tmp_dir}/${APP}"
}

download "${APP}"
