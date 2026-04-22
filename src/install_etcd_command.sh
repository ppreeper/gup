set -euo pipefail

APP="etcd"
REPO="etcd-io/etcd"
gup_fetch_release "${REPO}" 'contains("linux-amd64")'

download() {
    echo "download $1 version"
    echo "installing ${GUP_REL_VERSION}"

    local tmp_dir
    tmp_dir=$(gup_mktemp_dir)
    trap 'rm -rf "${tmp_dir}"' RETURN

    gup_download "${GUP_REL_DL}" "${tmp_dir}/${GUP_REL_FN}"
    _gup_extract_tarball "${tmp_dir}/${GUP_REL_FN}" "${tmp_dir}/etcd"

    if [ "$(id -u)" = 0 ]; then
        BDIR="/usr/local/bin"
    else
        BDIR="${HOME}/.local/bin"
        mkdir -p "${BDIR}"
    fi

    install "${tmp_dir}/etcd/etcd" "${BDIR}/etcd"
    install "${tmp_dir}/etcd/etcdctl" "${BDIR}/etcdctl"
    install "${tmp_dir}/etcd/etcdutl" "${BDIR}/etcdutl"
}

if [ -z "$(command -v "${APP}")" ]; then
    download new
else
    APPVER=$($(command -v "${APP}") --version 2>&1 | grep "etcd.*Version" | awk '{print $3}' | sed 's/^v//')
    if [ "${APPVER}" = "${GUP_REL_VERSION}" ]; then
        echo "${APP} version is current"
    else
        download "${GUP_REL_VERSION}"
    fi
fi
