set -euo pipefail

APP="zfsnap"
REPO="https://github.com/zfsnap/zfsnap"
BREPO="https://raw.githubusercontent.com/zfsnap/zfsnap"
vers=$(git ls-remote --tags "${REPO}" | grep "refs/tags/v2.*[0-9]$" | grep -v -e rc -e alpha | awk '{print $2}' | sed 's/refs\/tags\///' | sort -V | uniq | tail -1)

echo "installing ${vers}"

tmp_dir=$(gup_mktemp_dir)
trap 'rm -rf "${tmp_dir}"' RETURN

if [ "$(id -u)" = 0 ]; then
    SHARE_DIR="/usr/share/zfsnap"
    SBIN_DIR="/usr/sbin"
    DO_SUDO="sudo"
else
    SHARE_DIR="${HOME}/.local/share/zfsnap"
    SBIN_DIR="${HOME}/.local/bin"
    DO_SUDO=""
fi

${DO_SUDO} mkdir -p "${SHARE_DIR}/commands"

gup_download "${BREPO}/${vers}/share/zfsnap/core.sh" "${tmp_dir}/core.sh"
gup_download "${BREPO}/${vers}/share/zfsnap/commands/destroy.sh" "${tmp_dir}/destroy.sh"
gup_download "${BREPO}/${vers}/share/zfsnap/commands/recurseback.sh" "${tmp_dir}/recurseback.sh"
gup_download "${BREPO}/${vers}/share/zfsnap/commands/snapshot.sh" "${tmp_dir}/snapshot.sh"
gup_download "${BREPO}/${vers}/sbin/zfsnap.sh" "${tmp_dir}/zfsnap"

${DO_SUDO} install -m 0755 "${tmp_dir}/core.sh" "${SHARE_DIR}/core.sh"
${DO_SUDO} install -m 0755 "${tmp_dir}/destroy.sh" "${SHARE_DIR}/commands/destroy.sh"
${DO_SUDO} install -m 0755 "${tmp_dir}/recurseback.sh" "${SHARE_DIR}/commands/recurseback.sh"
${DO_SUDO} install -m 0755 "${tmp_dir}/snapshot.sh" "${SHARE_DIR}/commands/snapshot.sh"
${DO_SUDO} install -m 0755 "${tmp_dir}/zfsnap" "${SBIN_DIR}/zfsnap"
