set -eu

APP="btop"
REPO="aristocratos/btop"
gup_fetch_release "${REPO}" 'test("x86_64-unknown-linux-musl\\.tar\\.gz$")'

download() {
    echo "download $1 version"
    echo "installing ${GUP_REL_VERSION}"

    tmp_dir=$(gup_mktemp_dir)
    trap '[ -z "${tmp_dir:-}" ] || rm -rf "${tmp_dir}"' EXIT

    gup_download "${GUP_REL_DL}" "${tmp_dir}/${GUP_REL_FN}"
    # The archive contains its own top-level btop/ directory (with ./ entry prefix), so do not strip components.
    _gup_extract_tarball "${tmp_dir}/${GUP_REL_FN}" "${tmp_dir}" 0

    if [ "$(id -u)" = 0 ]; then
        PREFIX="/usr/local"
    else
        PREFIX="${HOME}/.local"
    fi

    # required directories
    mkdir -p "${PREFIX}/bin"
    mkdir -p "${PREFIX}/share/${APP}"
    mkdir -p "${PREFIX}/share/${APP}/themes"
    mkdir -p "${PREFIX}/share/applications"
    mkdir -p "${PREFIX}/share/icons/hicolor/48x48/apps"
    mkdir -p "${PREFIX}/share/icons/hicolor/scalable/apps"

    # btop binary
    install "${tmp_dir}/btop/bin/btop" "${PREFIX}/bin/btop"

    # doc
    cp "${tmp_dir}/btop/README.md" "${PREFIX}/share/${APP}/README.md"

    # Themes
    cp "${tmp_dir}/btop/themes/"* "${PREFIX}/share/${APP}/themes/"

    # desktop file
    cp "${tmp_dir}/btop/btop.desktop" "${PREFIX}/share/applications/btop.desktop"

    # icons
    cp "${tmp_dir}/btop/Img/icon.png" "${PREFIX}/share/icons/hicolor/48x48/apps/btop.png"
    cp "${tmp_dir}/btop/Img/icon.svg" "${PREFIX}/share/icons/hicolor/scalable/apps/btop.svg"
}

if [ -z "$(command -v "${APP}")" ]; then
    download new
else
    APPVER=$($(command -v "${APP}") --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
    if [ "${APPVER}" = "${GUP_REL_VERSION}" ]; then
        echo "${APP} version is current"
    else
        download "${GUP_REL_VERSION}"
    fi
fi
