set -eu

APP="act"
REPO="nektos/act"
# Assets are named act_Linux_x86_64.tar.gz; anchor the match so armv6/armv7
# siblings (act_Linux_armv6.tar.gz) do not ride along.
gup_fetch_release "${REPO}" 'test("Linux_x86_64\\.tar\\.gz$"; "i")'

download() {
    echo "download $1 version"
    echo "installing ${GUP_REL_VERSION}"

    tmp_dir=$(gup_mktemp_dir)
    trap '[ -z "${tmp_dir:-}" ] || rm -rf "${tmp_dir}"' EXIT

    gup_download "${GUP_REL_DL}" "${tmp_dir}/${GUP_REL_FN}"
    # The archive is flat (act, LICENSE, README.md), so do not strip components.
    _gup_extract_tarball "${tmp_dir}/${GUP_REL_FN}" "${tmp_dir}" 0
    _gup_install_binary "${tmp_dir}/${APP}"
}

if [ -z "$(command -v "${APP}")" ]; then
    download new
else
    APPVER=$($(command -v "${APP}") --version 2>&1 | grep "^${APP}" | awk '{print $3}')
    if [ "${APPVER}" = "${GUP_REL_VERSION}" ]; then
        echo "${APP} version is current"
    else
        download "${GUP_REL_VERSION}"
    fi
fi
