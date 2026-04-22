APP="minikube"
DL="https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64"

echo "installing latest ${APP}"

tmp_dir=$(gup_mktemp_dir)
trap 'rm -rf "${tmp_dir}"' RETURN

gup_download "${DL}" "${tmp_dir}/${APP}"
chmod +x "${tmp_dir}/${APP}"
_gup_install_binary "${tmp_dir}/${APP}"
