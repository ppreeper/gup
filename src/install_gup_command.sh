REPO="https://raw.githubusercontent.com/ppreeper/gup"

if [ "$(id -u)" = 0 ]; then
    IDIR="/usr/local/bin"
    sudo mkdir -p "${IDIR}"
    sudo wget -q "${REPO}/main/gup" -O "${IDIR}/gup"
    chmod +x "${IDIR}/gup"
else
    IDIR="${HOME}/.local/bin"
    mkdir -p "${IDIR}"
    wget -q "${REPO}/main/gup" -O "${IDIR}/gup"
    chmod +x "${IDIR}/gup"
fi
