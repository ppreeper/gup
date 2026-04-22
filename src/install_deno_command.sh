set -euo pipefail

APP="deno"
target="x86_64-unknown-linux-gnu"

deno_version="$(wget -qO- https://dl.deno.land/release-latest.txt)"
deno_uri="https://dl.deno.land/release/${deno_version}/deno-${target}.zip"

echo "installing ${deno_version}"

tmp_dir=$(gup_mktemp_dir)
trap 'rm -rf "${tmp_dir}"' RETURN

gup_download "${deno_uri}" "${tmp_dir}/deno.zip"
unzip -d "${tmp_dir}" -o "${tmp_dir}/deno.zip"
_gup_install_binary "${tmp_dir}/deno"
