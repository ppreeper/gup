set -eu

APP="task"
REPO="go-task/task"
gup_fetch_release "${REPO}" 'contains("linux_amd64.tar.gz")'

download() {
    echo "download $1 version"
    echo "installing ${GUP_REL_VERSION}"

    tmp_dir=$(gup_mktemp_dir)
    trap '[ -z "${tmp_dir:-}" ] || rm -rf "${tmp_dir}"' EXIT

    gup_download "${GUP_REL_DL}" "${tmp_dir}/${GUP_REL_FN}"
    # The archive is flat (task, LICENSE, README.md, completion/...), so do not strip components.
    _gup_extract_tarball "${tmp_dir}/${GUP_REL_FN}" "${tmp_dir}" 0
    _gup_install_binary "${tmp_dir}/${APP}"
}

if [ -z "$(command -v "${APP}")" ]; then
    download new
else
    APPVER=$($(command -v "${APP}") --version 2>&1 | tr -d 'v')
    if [ "${APPVER}" = "${GUP_REL_VERSION}" ]; then
        echo "${APP} version is current"
    else
        download "${GUP_REL_VERSION}"
    fi
fi
