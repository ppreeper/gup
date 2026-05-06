set -euo pipefail

APP="mkcert"

echo "installing ${APP}"

tmp_dir=$(gup_mktemp_dir)
trap '[ -z "${tmp_dir:-}" ] || rm -rf "${tmp_dir}"' RETURN

gup_download "https://dl.filippo.io/mkcert/latest?for=linux/amd64" "${tmp_dir}/${APP}"
_gup_install_binary "${tmp_dir}/${APP}"
