APP="hx"
REPO="helix-editor/helix"
RURL="https://api.github.com/repos/${REPO}/releases/latest"
vers=$(wget -qO- "${RURL}" | jq .tag_name | tr -d '"' | tr -d 'v')
DL=$(wget -qO- "${RURL}" | jq '.assets[] | select(.name | contains ("x86_64-linux")) | .browser_download_url' | tr -d '"')
FN=$(wget -qO- "${RURL}" | jq '.assets[] | select(.name | contains ("x86_64-linux")) | .name' | tr -d '"')

IDIR=${HOME}/.config/helix
BDIR=${HOME}/.local/helix

function download() {
    echo "download $1 version"
    echo "installing ${vers}"
    mkdir -p "${IDIR}" "${BDIR}"
    touch "${IDIR}/config.toml"
    rm -f /tmp/"${FN}"
    wget -qc "${DL}" -O /tmp/"${FN}"
    rm -rf "${BDIR:?}"/*
    tar axf /tmp/"${FN}" --strip-components=1 -C "${BDIR}"
    ln -sf "${BDIR}/hx" "${HOME}/.local/bin/hx"
    rm -f /tmp/"${FN}"
}


if [ -z "$(which ${APP})" ]; then
    download new
else
    APPVER=$($(which ${APP}) -V 2>&1 | grep -e "^helix" | awk '{print $2}')
    if [ "${APPVER}" = "${vers}" ]; then
        echo "${APP} version is current"
    else
        download "${vers}"
    fi
fi
