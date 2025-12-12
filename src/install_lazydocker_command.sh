APP="lazydocker"
REPO="jesseduffield/lazydocker"
RURL="https://api.github.com/repos/${REPO}/releases/latest"
vers=$(wget -qO- "${RURL}" | jq .tag_name | tr -d '"' | tr -d 'v')
DL=$(wget -qO- "${RURL}" | jq '.assets[] | select(.name | contains("inux_x86_64")) | .browser_download_url' | tr -d '"')
FN=$(wget -qO- "${RURL}" | jq '.assets[] | select(.name | contains("inux_x86_64")) | .name' | tr -d '"')

function download() {
    echo "download $1 version"
    echo "installing ${vers}"
    rm -rf /tmp/lazydocker /tmp/"${FN}"
    wget -qc "${DL}" -O /tmp/"${FN}"
    tar axf /tmp/"${FN}" lazydocker
    if [ "$(id -u)" == 0 ]; then
        IDIR="/usr/local/bin"
        sudo mkdir -p "${IDIR}"
        sudo install lazydocker "${IDIR}"
    else
        IDIR="${HOME}/.local/bin"
        mkdir -p "${IDIR}"
        install lazydocker "${IDIR}"
    fi
    rm -rf lazydocker /tmp/"${FN}"
}


if [ -z "$(which ${APP})" ]; then
    download new
else
  APPVER=$($(which ${APP}) --version 2>&1 | awk '{print $6}' | sed 's/,//g' | awk -F'=' '{print $2}')
  if [ "${APPVER}" = "${vers}" ]; then
      echo "${APP} version is current"
  else
      download "${vers}"
  fi
fi
