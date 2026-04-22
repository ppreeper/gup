REPO="ryanoasis/nerd-fonts"
FONTDIR="${HOME}/.local/share/fonts"

download() {
    echo "installing $1 font"
    local DL
    DL=$(echo "${GUP_REL_JSON}" | jq -r '.assets[] | select(.name | contains("tar.xz")) | .browser_download_url' | grep "$1")
    for font in ${DL}; do
        local tmp_dir
        tmp_dir=$(gup_mktemp_dir)
        trap 'rm -rf "${tmp_dir}"' RETURN

        gup_download "${font}" "${tmp_dir}/font.tar.xz"
        tar -xf "${tmp_dir}/font.tar.xz" -C "${FONTDIR}" --wildcards "*ttf"
    done
}

gup_fetch_release "${REPO}" 'contains("tar.xz")'
fonts="${args[font]}"
for font in ${fonts}; do
  download "$font"
done
