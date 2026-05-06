set -euo pipefail

APP="kubectl"
STABLE_URL="https://storage.googleapis.com/kubernetes-release/release/stable.txt"
BASE_URL="https://storage.googleapis.com/kubernetes-release/release"

tmp_dir=$(gup_mktemp_dir)
trap '[ -z "${tmp_dir:-}" ] || rm -rf "${tmp_dir}"' RETURN

gup_download "${STABLE_URL}" "${tmp_dir}/stable.txt"
stable=$(cat "${tmp_dir}/stable.txt")
gup_download "${BASE_URL}/${stable}/bin/linux/amd64/kubectl" "${tmp_dir}/${APP}"
_gup_install_binary "${tmp_dir}/${APP}"
