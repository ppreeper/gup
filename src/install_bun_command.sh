set -euo pipefail

APP="bun"
REPO="oven-sh/bun"
target="linux-x64"
gup_fetch_release "${REPO}" 'contains("linux-x64.zip")'

download() {
    echo "download $1 version"
    echo "installing ${GUP_REL_VERSION}"

    local tmp_dir
    tmp_dir=$(gup_mktemp_dir)
    trap '[ -z "${tmp_dir:-}" ] || rm -rf "${tmp_dir}"' RETURN

    if [ "$(id -u)" = 0 ]; then
        BDIR="/usr/local"
        sudo mkdir -p "${BDIR}/bin"
        grep "BUN_INSTALL=${BDIR}" /etc/environment >/dev/null || echo "BUN_INSTALL=${BDIR}" | sudo tee -a /etc/environment
        grep "export BUN_INSTALL" /etc/profile >/dev/null || echo "export BUN_INSTALL=${BDIR}" | sudo tee -a /etc/profile
        grep 'export PATH=$BUN_INSTALL/bin:$PATH' /etc/profile >/dev/null || echo 'export PATH=$BUN_INSTALL/bin:$PATH' | sudo tee -a /etc/profile
    else
        BDIR="${HOME}/.bun"
        mkdir -p "${BDIR}/bin"
        grep "export BUN_INSTALL" "${HOME}/.bashrc" >/dev/null || echo "export BUN_INSTALL=${BDIR}" >>"${HOME}/.bashrc"
        grep 'export PATH=$BUN_INSTALL/bin:$PATH' "${HOME}/.bashrc" >/dev/null || echo 'export PATH=$BUN_INSTALL/bin:$PATH' >>"${HOME}/.bashrc"
    fi

    gup_download "${GUP_REL_DL}" "${tmp_dir}/${GUP_REL_FN}"
    _gup_extract_zip "${tmp_dir}/${GUP_REL_FN}" "${tmp_dir}"
    if [ "$(id -u)" = 0 ]; then
        sudo install "${tmp_dir}/${APP}-${target}/${APP}" "${BDIR}/bin/${APP}"
    else
        install "${tmp_dir}/${APP}-${target}/${APP}" "${BDIR}/bin/${APP}"
    fi
    ln -f -s "${BDIR}/bin/bun" "${BDIR}/bin/bunx"
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
