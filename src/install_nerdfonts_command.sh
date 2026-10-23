set -eu

REPO="ryanoasis/nerd-fonts"
FONTDIR="${HOME}/.local/share/fonts"

download() {
    echo "installing $1 font"
    dl_urls=$(printf '%s\n' "${GUP_REL_JSON}" | jq -r '.assets[] | select(.name | contains("tar.xz")) | .browser_download_url' | grep "$1")
    printf '%s\n' "${dl_urls}" | while IFS= read -r font; do
        [ -z "${font}" ] && continue
        tmp_dir=$(gup_mktemp_dir)

        gup_download "${font}" "${tmp_dir}/font.tar.xz"
        mkdir -p "${FONTDIR}"
        tar -xf "${tmp_dir}/font.tar.xz" -C "${FONTDIR}" --wildcards "*ttf"
        rm -rf "${tmp_dir}"
    done
}

gup_fetch_release "${REPO}" 'contains("tar.xz")'
fonts="${font}"
printf '%s\n' "${fonts}" | while IFS= read -r font; do
    [ -z "${font}" ] && continue
    download "$font"
done
