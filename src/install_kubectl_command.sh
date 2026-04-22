local_tmp_dir=$(gup_mktemp_dir)
trap 'rm -rf "${local_tmp_dir}"' RETURN

curl -Lo "${local_tmp_dir}/kubectl" "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install "${local_tmp_dir}/kubectl" /usr/local/bin
