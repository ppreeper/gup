APP="btop"
REPO="aristocratos/btop"
PREFIX="/usr/local"
gup_fetch_release "${REPO}" 'contains("x86_64") and contains(".tbz")'

download() {
    echo "download $1 version"
    echo "installing ${GUP_REL_VERSION}"

    local tmp_dir
    tmp_dir=$(gup_mktemp_dir)
    trap 'rm -rf "${tmp_dir}"' RETURN

    gup_download "${GUP_REL_DL}" "${tmp_dir}/${GUP_REL_FN}"
    _gup_extract_tarball "${tmp_dir}/${GUP_REL_FN}" "${tmp_dir}/${APP}"

    # required directories
    sudo mkdir -p "${PREFIX}/bin"
    sudo mkdir -p "${PREFIX}/share/${APP}"
    sudo mkdir -p "${PREFIX}/share/${APP}/themes"
    sudo mkdir -p "${PREFIX}/share/applications"
    sudo mkdir -p "${PREFIX}/share/icons/hicolor/48x48/apps"
    sudo mkdir -p "${PREFIX}/share/icons/hicolor/scalable/apps"

    # btop binary
    sudo install "${tmp_dir}/btop/bin/btop" "${PREFIX}/bin/btop"

    # doc
    sudo cp "${tmp_dir}/btop/README.md" "${PREFIX}/share/${APP}/README.md"

    # Themes
    sudo cp "${tmp_dir}/btop/themes/"* "${PREFIX}/share/${APP}/themes/"

    # desktop file
    sudo cp "${tmp_dir}/btop/btop.desktop" "${PREFIX}/share/applications/btop.desktop"

    # icons
    sudo cp "${tmp_dir}/btop/Img/icon.png" "${PREFIX}/share/icons/hicolor/48x48/apps/btop.png"
    sudo cp "${tmp_dir}/btop/Img/icon.svg" "${PREFIX}/share/icons/hicolor/scalable/apps/btop.svg"
}

if [ -z "$(command -v "${APP}")" ]; then
    download new
else
    APPVER=$($(command -v "${APP}") --version | grep "^btop version:" | awk -F':' '{print $2}' | sed -E 's/\x1B\[[0-9;]*[a-zA-Z]//g' | awk '{$1=$1; print}')
    if [ "${APPVER}" = "${GUP_REL_VERSION}" ]; then
        echo "${APP} version is current"
    else
        download "${GUP_REL_VERSION}"
    fi
fi
