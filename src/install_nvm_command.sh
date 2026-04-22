set -euo pipefail

REPO="nvm-sh/nvm"
vers=$(gup_get_latest_release "${REPO}")

DLREPO="https://raw.githubusercontent.com/nvm-sh/nvm"

tmp_dir=$(gup_mktemp_dir)
trap 'rm -rf "${tmp_dir}"' RETURN

gup_download "${DLREPO}/${vers}/install.sh" "${tmp_dir}/install.sh"
bash "${tmp_dir}/install.sh"
