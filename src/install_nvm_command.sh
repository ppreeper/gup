REPO="https://github.com/nvm-sh/nvm"
DLREPO="https://raw.githubusercontent.com/nvm-sh/nvm"
vers=$(git ls-remote --tags ${REPO} | grep "refs/tags.*[0-9]$" | awk '{print $2}' | sed 's/refs\/tags\///g' | sort -V | uniq | tail -1)

wget -qO- "${DLREPO}/${vers}/install.sh" | bash
