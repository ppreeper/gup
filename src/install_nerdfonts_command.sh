FONTDIR="${HOME}/.local/share/fonts"
REPO="https://github.com/ryanoasis/nerd-fonts"

vers=$(git ls-remote --tags ${REPO} | grep "refs/tags.*[0-9]$" | awk '{print $2}' | sed 's/refs\/tags\///g' | sort -V | uniq | tail -1)

download() {
    echo "download $1 font"
    FN=${vers}-$1.zip
    rm -f /tmp/${FN}
    wget -qc ${REPO}/releases/download/${vers}/$1.zip -O /tmp/${FN}
    mkdir -p ${FONTDIR}
    unzip -qo -d ${FONTDIR} /tmp/${FN}
    rm -f /tmp/${FN}
}

fonts=''
eval "fonts=(${args[font]})"

for font in "${fonts[@]}"; do
  download $font
done
