REPO="ryanoasis/nerd-fonts"
RURL="https://api.github.com/repos/${REPO}/releases/latest"
FONTDIR="${HOME}/.local/share/fonts"

download() {
    echo "installing $1 font"
    DL=$(wget -qO- "${RURL}" | jq '.assets[] | select(.name | contains("tar.xz")) | .browser_download_url' | tr -d '"' | grep "$1")
    for font in ${DL}; do
        rm -f /tmp/font.tar.xz
        wget -qc "${font}" -O /tmp/font.tar.xz
        tar -xf /tmp/font.tar.xz -C "${FONTDIR}" --wildcards "*ttf"
        rm -f /tmp/font.tar.xz
    done
}

fonts="${args[font]}"
for font in ${fonts}; do
  download "$font"
done
