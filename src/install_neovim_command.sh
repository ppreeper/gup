APP="nvim"
REPO="neovim/neovim"
RURL="https://api.github.com/repos/${REPO}/releases/latest"
vers=$(wget -qO- "${RURL}" | jq .tag_name | tr -d '"' | tr -d 'v')
DL=$(wget -qO- "${RURL}" | jq '.assets[] | select(.name | contains("linux-x86_64.tar.gz")) | .browser_download_url' | tr -d '"')
FN=$(wget -qO- "${RURL}" | jq '.assets[] | select(.name | contains("linux-x86_64.tar.gz")) | .name' | tr -d '"')

IDIR=${HOME}/.local/nvim
BDIR=${HOME}/.local/bin

function download() {
    echo "download $1 version"
    echo "installing ${vers}"
    rm -f /tmp/"${FN}"
    wget -qc "${DL}" -O /tmp/"${FN}"
    rm -rf "${IDIR:?}"
    mkdir -p "${IDIR}"
    tar -zxf /tmp/"${FN}" --strip-components=1 -C "${IDIR}"
    ln -sf "${IDIR}/bin/nvim" "${BDIR}/nvim"
    rm -f /tmp/"${FN}"
}

if [ -z "$(which ${APP})" ]; then
    download new
else
    APPVER=$($(which "${APP}") --version | grep -i "^${APP}" | awk '{print $2}' | tr -d 'v')
    if [ "${APPVER}" = "${vers}" ]; then
        echo "${APP} version is current"
    else
        download "${vers}"
    fi
fi
