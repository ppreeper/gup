APP="lazygit"
REPO="jesseduffield/lazygit"
RURL="https://api.github.com/repos/${REPO}/releases/latest"
vers=$(wget -qO- "${RURL}" | jq .tag_name | tr -d '"' | tr -d 'v')
DL=$(wget -qO- "${RURL}" | jq '.assets[] | select(.name | contains("linux_x86_64")) | .browser_download_url' | tr -d '"')
FN=$(wget -qO- "${RURL}" | jq '.assets[] | select(.name | contains("linux_x86_64")) | .name' | tr -d '"')

function download() {
    echo "download $1 version"
    echo "installing ${vers}"
    rm -rf /tmp/lazygit /tmp/"${FN}"
    wget -qc "${DL}" -O /tmp/"${FN}"
    tar axf /tmp/"${FN}" lazygit
    if [ "$(id -u)" == 0 ]; then
        IDIR="/usr/local/bin"
        sudo mkdir -p "${IDIR}"
        sudo install lazygit "${IDIR}"
    else
        IDIR="${HOME}/.local/bin"
        mkdir -p "${IDIR}"
        install lazygit "${IDIR}"
    fi
    rm -rf lazygit /tmp/"${FN}"
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
