set -eu

APP="gitleaks"
REPO="gitleaks/gitleaks"
gup_fetch_release "${REPO}" 'test("linux_x64\\.tar\\.gz$")'

download() {
    echo "download $1 version"
    echo "installing ${GUP_REL_VERSION}"

    tmp_dir=$(gup_mktemp_dir)
    trap '[ -z "${tmp_dir:-}" ] || rm -rf "${tmp_dir}"' EXIT

    gup_download "${GUP_REL_DL}" "${tmp_dir}/${GUP_REL_FN}"
    # The archive is flat (gitleaks, LICENSE, README.md).
    tar axf "${tmp_dir}/${GUP_REL_FN}" -C "${tmp_dir}" "${APP}"
    _gup_install_binary "${tmp_dir}/${APP}"
}

if [ -z "$(command -v "${APP}")" ]; then
    download new
else
    APPVER=$($(command -v "${APP}") version 2>&1 | head -n 1)
    if [ "${APPVER}" = "${GUP_REL_VERSION}" ]; then
        echo "${APP} version is current"
    else
        download "${GUP_REL_VERSION}"
    fi
fi
