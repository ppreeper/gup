REPO="nvm-sh/nvm"
RURL="https://api.github.com/repos/${REPO}/releases/latest"
vers=$(wget -qO- "${RURL}" | jq .tag_name | tr -d '"' | tr -d 'v')

DLREPO="https://raw.githubusercontent.com/nvm-sh/nvm"
wget -qO- "${DLREPO}/${vers}/install.sh" | bash
