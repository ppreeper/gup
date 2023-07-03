APP="nvim"
REPO="https://github.com/neovim/neovim"
vers=$(git ls-remote --tags ${REPO} | grep "refs/tags.*[0-9]$" | awk '{print $2}' | sed 's/refs\/tags\///g' | sort -V | uniq | tail -1)

IDIR=${HOME}/.local/nvim
BDIR=${HOME}/.local/bin

function download() {
    echo "download $1 version"
    echo "installing ${vers}"
    wget -qc ${REPO}/releases/download/${vers}/nvim-linux64.tar.gz
    mkdir -p ${IDIR}
    rm -rf ${IDIR}/*
    tar -zxf nvim-linux64.tar.gz --strip-components=1 -C ${IDIR}
    ln -sf ${IDIR}/bin/nvim ${BDIR}/nvim
    rm -f nvim-linux64.tar.gz
}

if [ -z $(which ${APP}) ]; then
    download new
else
    APPBIN=$(which ${APP})
    APPVER=$(${APPBIN} --version | grep -i "^${APP}" | awk '{print $2}')
    [ "${APPVER}" = "${vers}" ] && echo "${APP} version is current" || download ${vers}
fi