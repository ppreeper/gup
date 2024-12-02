target="linux-x64.tar.xz"
node_version="$(wget -qO- https://nodejs.org/download/release/index.tab | awk '{print $10,$1}' | grep -v "^-" | awk '{print $2}' | grep -v "^version" | sort -V | tail -1)"
node_uri="https://nodejs.org/dist/${node_version}/node-${node_version}-${target}"
installer="/tmp/node-${target}"
iversion=$(node --version 2&>1 || echo "")

sudo mkdir -p /usr/local/share/node
sudo rm -rf /usr/local/share/node/*

rm -f "${installer}"
wget -qO "${installer}" "${node_uri}"
sudo tar axf "${installer}" --strip-components=1 -C /usr/local/share/node
rm -f "${installer}"

sudo rm -f /usr/local/bin/node
sudo ln -s /usr/local/share/node/bin/node /usr/local/bin/node
sudo rm -f /usr/local/bin/npm
sudo ln -s /usr/local/share/node/bin/npm /usr/local/bin/npm
sudo rm -f /usr/local/bin/npx
sudo ln -s /usr/local/share/node/bin/npx /usr/local/bin/npx
sudo rm -f /usr/local/bin/corepack
sudo ln -s /usr/local/share/node/bin/corepack /usr/local/bin/corepack
