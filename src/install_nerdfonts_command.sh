set -euo pipefail

REPO="ryanoasis/nerd-fonts"
FONTDIR="${HOME}/.local/share/fonts"

download() {
    echo "installing $1 font"
    local dl_urls
    dl_urls=$(echo "${GUP_REL_JSON}" | jq -r '.assets[] | select(.name | contains("tar.xz")) | .browser_download_url' | grep "$1")
    while IFS= read -r font; do
        [ -z "${font}" ] && continue
        local tmp_dir
        tmp_dir=$(gup_mktemp_dir)
        trap 'rm -rf "${tmp_dir}"' RETURN

        gup_download "${font}" "${tmp_dir}/font.tar.xz"
        mkdir -p "${FONTDIR}"
        tar -xf "${tmp_dir}/font.tar.xz" -C "${FONTDIR}" --wildcards "*ttf"
    done <<< "${dl_urls}"
}

gup_fetch_release "${REPO}" 'contains("tar.xz")'
fonts="${args[font]}"
while IFS= read -r font; do
    [ -z "${font}" ] && continue
    download "$font"
done <<< "${fonts}"
