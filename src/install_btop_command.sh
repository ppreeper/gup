APP="btop"
REPO="https://github.com/aristocratos/btop"
vers=$(git ls-remote --tags "${REPO}" | grep "refs/tags.*[0-9]$" | awk '{print $2}' | sed 's/refs\/tags\///g' | sort -V | uniq | tail -1)

PREFIX="/usr/local"

function download() {
    echo "download $1 version"
    echo "installing ${vers}"
    FN="${APP}-x86_64-linux-musl.tbz"

    rm -f /tmp/btop.tbz
    wget -qc "${REPO}/releases/download/${vers}/${FN}" -O /tmp/btop.tbz

    rm -rf /tmp/btop
    mkdir -p /tmp/btop
    tar -xjf /tmp/btop.tbz -C /tmp/btop --strip-components=2

    # required directories
    mkdir -p "${PREFIX}/bin"
    mkdir -p "${PREFIX}/share/${APP}"
    mkdir -p "${PREFIX}/share/${APP}/themes"
    mkdir -p "${PREFIX}/share/applications"
    mkdir -p "${PREFIX}/share/icons/hicolor/48x48/apps"
    mkdir -p "${PREFIX}/share/icons/hicolor/scalable/apps"

    # btop binary
    mkdir -p "${PREFIX}/bin"
    cp /tmp/btop/bin/btop "${PREFIX}/bin/"

    # doc
    cp /tmp/btop/README.md "${PREFIX}/share/${APP}/README.md"

    # Themes
    cp /tmp/btop/themes/* "${PREFIX}/share/${APP}/themes/"

    # desktop file
    cp /tmp/btop/btop.desktop "${PREFIX}/share/applications/btop.desktop"

    # icons
    cp /tmp/btop/Img/icon.png "${PREFIX}/share/icons/hicolor/48x48/apps/btop.png"
    cp /tmp/btop/Img/icon.svg "${PREFIX}/share/icons/hicolor/scalable/apps/btop.svg"

    # cleanup
    rm -rf /tmp/btop
    rm -f /tmp/btop.tbz
}

if [ -z $(which "${APP}") ]; then
    download new
else
    APPBIN=$(which "${APP}")
    APPVER=$(${APPBIN} --version | grep "^btop version:" | awk -F':' '{print $2}' | sed -E 's/\x1B\[[0-9;]*[a-zA-Z]//g' | awk '{$1=$1; print}')
    version=$(echo "${vers}" | sed 's/^v//')
    [ "${APPVER}" = "${version}" ] && echo "${APP} version is current" || download "${vers}"
fi