REPO="https://raw.githubusercontent.com/ppreeper/gup"

if [ "$(id -u)" == 0 ]; then
    IDIR="/usr/local/bin"
    sudo wget -q "${REPO}/main/gup" -O "${IDIR}/gup"
    chmod +x "${IDIR}/gup"
else
    IDIR="${HOME}/.local/bin"
    wget -q "${REPO}/main/gup" -O "${IDIR}/gup"
    chmod +x "${IDIR}/gup"
fi
