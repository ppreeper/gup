target="x86_64-unknown-linux-gnu"
deno_version="$(wget -qO- https://dl.deno.land/release-latest.txt)"
deno_uri="https://dl.deno.land/release/${deno_version}/deno-${target}.zip"

local_tmp_dir=$(gup_mktemp_dir)
trap 'rm -rf "${local_tmp_dir}"' RETURN

wget -qO "${local_tmp_dir}/deno.zip" "${deno_uri}"
sudo unzip -d /usr/local/bin -o "${local_tmp_dir}/deno.zip"
