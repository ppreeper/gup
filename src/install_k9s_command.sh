APP="k9s"
REPO="derailed/k9s"
RURL="https://api.github.com/repos/${REPO}/releases/latest"
vers=$(wget -qO- "${RURL}" | jq .tag_name | tr -d '"' | tr -d 'v')
DL=$(wget -qO- "${RURL}" | jq '.assets[] | select(.name | (contains("json") | not) and contains("Linux") and contains("amd64")) | .browser_download_url' | tr -d '"')
FN=$(wget -qO- "${RURL}" | jq '.assets[] | select(.name | (contains("json") | not) and contains("Linux") and contains("amd64")) | .name' | tr -d '"')


function download() {
    echo "download $1 version"
    echo "installing ${vers}"
    rm -rf /tmp/"${FN}" /tmp/k9s
    wget -qc "${DL}" -O /tmp/"${FN}"
    tar axf /tmp/"${FN}" k9s
    if [ "$(id -u)" == 0 ]; then
        IDIR="/usr/local/bin"
        mkdir -p "${IDIR}"
        install k9s "$IDIR"
    else
        IDIR="${HOME}/.local/bin"
        mkdir -p "${IDIR}"
        install k9s "$IDIR"
    fi
    rm -rf k9s /tmp/"${FN}"
}


if [ -z "$(which ${APP})" ]; then
    download new
else
  APPVER=$($(which ${APP}) version 2>&1 | grep Version | awk '{print $2}' | tr -d 'v')
  if [ "${APPVER}" = "${vers}" ]; then
      echo "${APP} version is current"
  else
      download "${vers}"
  fi
fi
