APP="mkcert"

echo "installing ${APP}"

tmp_dir=$(gup_mktemp_dir)
trap 'rm -rf "${tmp_dir}"' RETURN

gup_download "https://dl.filippo.io/mkcert/latest?for=linux/amd64" "${tmp_dir}/${APP}"
chmod +x "${tmp_dir}/${APP}"
_gup_install_binary "${tmp_dir}/${APP}"
