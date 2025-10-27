APP="nvim"
REPO="https://github.com/neovim/neovim"
vers=$(git ls-remote --tags ${REPO} | grep "refs/tags.*[0-9]$" | awk '{print $2}' | sed 's/refs\/tags\///g' | sort -V | uniq | tail -1)

IDIR=${HOME}/.local/nvim
BDIR=${HOME}/.local/bin
ARCH="linux-x86_64"

function download() {
    echo "download $1 version"
    echo "installing ${vers}"
    fname="nvim-${ARCH}.tar.gz"
    wget -qc "${REPO}/releases/download/${vers}/${fname}"
    rm -rf "${IDIR:?}"
    mkdir -p "${IDIR}"
    tar -zxf "${fname}" --strip-components=1 -C "${IDIR}"
    ln -sf "${IDIR}/bin/nvim" "${BDIR}/nvim"
    rm -f "${fname}"
}

if [ -z "$(which ${APP})" ]; then
    download new
else
    APPBIN=$(which "${APP}")
    APPVER=$("${APPBIN}" --version | grep -i "^${APP}" | awk '{print $2}')
    [ "${APPVER}" = "${vers}" ] && echo "${APP} version is current" || download "${vers}"
fi
