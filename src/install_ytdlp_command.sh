set -eu

APP="yt-dlp"
REPO="yt-dlp/yt-dlp"
# endswith("_linux") matches only yt-dlp_linux (glibc standalone binary); skip .zip, aarch64, armv7l, musllinux assets.
gup_fetch_release "${REPO}" 'endswith("_linux")'

download() {
    echo "download $1 version"
    echo "installing ${GUP_REL_VERSION}"

    tmp_dir=$(gup_mktemp_dir)
    trap '[ -z "${tmp_dir:-}" ] || rm -rf "${tmp_dir}"' EXIT

    gup_download "${GUP_REL_DL}" "${tmp_dir}/${GUP_REL_FN}"
    # The asset file is named yt-dlp_linux; install it under the yt-dlp command name.
    _gup_install_binary "${tmp_dir}/${GUP_REL_FN}" "${APP}"
}

if [ -z "$(command -v "${APP}")" ]; then
    download new
else
    APPVER=$($(command -v "${APP}") --version 2>&1)
    if [ "${APPVER}" = "${GUP_REL_VERSION}" ]; then
        echo "${APP} version is current"
    else
        download "${GUP_REL_VERSION}"
    fi
fi
