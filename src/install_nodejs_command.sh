set -euo pipefail

target="linux-x64.tar.xz"

tmp_dir=$(gup_mktemp_dir)
trap 'rm -rf "${tmp_dir}"' RETURN

if command -v curl >/dev/null 2>&1; then
    node_version="$(curl -fsSL https://nodejs.org/download/release/index.tab | awk '{print $10,$1}' | grep -v "^-" | awk '{print $2}' | grep -v "^version" | sort -V | tail -1)"
else
    node_version="$(wget -qO- https://nodejs.org/download/release/index.tab | awk '{print $10,$1}' | grep -v "^-" | awk '{print $2}' | grep -v "^version" | sort -V | tail -1)"
fi
node_uri="https://nodejs.org/dist/${node_version}/node-${node_version}-${target}"

echo "installing ${node_version}"

gup_download "${node_uri}" "${tmp_dir}/node-${target}"

if [ "$(id -u)" = 0 ]; then
    IDIR="/usr/local/share/node"
    BDIR="/usr/local/bin"
    sudo rm -rf "${IDIR}"
    sudo mkdir -p "${IDIR}"
    sudo tar axf "${tmp_dir}/node-${target}" --strip-components=1 -C "${IDIR}"
    sudo rm -f "${BDIR}/node"
    sudo ln -s "${IDIR}/bin/node" "${BDIR}/node"
    sudo rm -f "${BDIR}/npm"
    sudo ln -s "${IDIR}/bin/npm" "${BDIR}/npm"
    sudo rm -f "${BDIR}/npx"
    sudo ln -s "${IDIR}/bin/npx" "${BDIR}/npx"
    sudo rm -f "${BDIR}/corepack"
    sudo ln -s "${IDIR}/bin/corepack" "${BDIR}/corepack"
else
    IDIR="${HOME}/.local/share/node"
    BDIR="${HOME}/.local/bin"
    mkdir -p "${BDIR}"
    rm -rf "${IDIR}"
    mkdir -p "${IDIR}"
    tar axf "${tmp_dir}/node-${target}" --strip-components=1 -C "${IDIR}"
    rm -f "${BDIR}/node"
    ln -s "${IDIR}/bin/node" "${BDIR}/node"
    rm -f "${BDIR}/npm"
    ln -s "${IDIR}/bin/npm" "${BDIR}/npm"
    rm -f "${BDIR}/npx"
    ln -s "${IDIR}/bin/npx" "${BDIR}/npx"
    rm -f "${BDIR}/corepack"
    ln -s "${IDIR}/bin/corepack" "${BDIR}/corepack"
fi
