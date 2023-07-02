CMD="hx"
REPO="https://github.com/helix-editor/helix"
vers=$(git ls-remote --tags ${REPO} | grep "refs/tags.*[0-9]$" | awk '{print $2}' | sed 's/refs\/tags\///' | grep -v "^v" | sort -V | uniq | tail -1)

IDIR=${HOME}/.config/helix
BDIR=${HOME}/.local/helix

function download() {
    echo "download $1 version"
    echo "Installing ${vers}"
    mkdir -p ${IDIR} ${BDIR}
    touch ${IDIR}/config.toml
    FN=helix-${vers}-x86_64-linux.tar.xz
    rm -f /tmp/${FN}
    wget -qc ${REPO}/releases/download/${vers}/${FN} -O /tmp/${FN}
    rm -rf ${BDIR}/*
    tar axf /tmp/${FN} --strip-components=1 -C ${BDIR}
    ln -sf ${BDIR}/hx ${HOME}/.local/bin/hx
    rm -f /tmp/${FN}
}


if [ -z $(which ${CMD}) ]; then
    download new
else
  APP=$(which ${CMD})
  APPVER=$(${APP} -V | grep -e "^helix" | awk '{print $2}')
  [ "${APPVER}" = "${vers}" ] && echo "${CMD} version is current" || download new
fi
