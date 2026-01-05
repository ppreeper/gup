APP="btop"
REPO="aristocratos/btop"
RURL="https://api.github.com/repos/${REPO}/releases/latest"
vers=$(wget -qO- "${RURL}" | jq .tag_name | tr -d '"')
DL=$(wget -qO- "${RURL}" | jq '.assets[] | select(.name | contains ("x86_64-linux")) | .browser_download_url' | tr -d '"')
FN=$(wget -qO- "${RURL}" | jq '.assets[] | select(.name | contains ("x86_64-linux")) | .name' | tr -d '"')

PREFIX="/usr/local"

function download() {
    echo "download $1 version"
    echo "installing ${vers}"

    rm -f /tmp/"${FN}"
    wget -qO /tmp/"${FN}" "${DL}"

    rm -f /tmp/"${APP}"
    mkdir -p /tmp/"${APP}"
    tar -xjf /tmp/"${FN}" -C /tmp/"${APP}" --strip-components=2

    # required directories
    sudo mkdir -p "${PREFIX}/bin"
    sudo mkdir -p "${PREFIX}/share/${APP}"
    sudo mkdir -p "${PREFIX}/share/${APP}/themes"
    sudo mkdir -p "${PREFIX}/share/applications"
    sudo mkdir -p "${PREFIX}/share/icons/hicolor/48x48/apps"
    sudo mkdir -p "${PREFIX}/share/icons/hicolor/scalable/apps"

    # btop binary
    sudo mkdir -p "${PREFIX}/bin"
    sudo install /tmp/btop/bin/btop "${PREFIX}/bin/btop"

    # doc
    sudo cp /tmp/btop/README.md "${PREFIX}/share/${APP}/README.md"

    # Themes
    sudo cp /tmp/btop/themes/* "${PREFIX}/share/${APP}/themes/"

    # desktop file
    sudo cp /tmp/btop/btop.desktop "${PREFIX}/share/applications/btop.desktop"

    # icons
    sudo cp /tmp/btop/Img/icon.png "${PREFIX}/share/icons/hicolor/48x48/apps/btop.png"
    sudo cp /tmp/btop/Img/icon.svg "${PREFIX}/share/icons/hicolor/scalable/apps/btop.svg"

    # cleanup
    rm -f /tmp/"${APP}"
    rm -f /tmp/"${FN}"
}

if [ -z "$(which ${APP})" ]; then
    download new
else
    APPVER=$($(which ${APP}) --version | grep "^btop version:" | awk -F':' '{print $2}' | sed -E 's/\x1B\[[0-9;]*[a-zA-Z]//g' | awk '{$1=$1; print}')
    version=$(echo "${vers}" | sed 's/^v//')
    if [ "${APPVER}" = "${version}" ]; then
        echo "${APP} version is current"
    else
        download "${vers}"
    fi
fi