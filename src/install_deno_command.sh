target="x86_64-unknown-linux-gnu"
deno_version="$(wget -qO- https://dl.deno.land/release-latest.txt)"
deno_uri="https://dl.deno.land/release/${deno_version}/deno-${target}.zip"
installer="/tmp/deno.zip"
iversion="deno --version | grep "^deno" | awk '{print $2}'"

wget -qO "${installer}" "${deno_uri}"
sudo unzip -d /usr/local/bin -o "${installer}"
rm -f "${installer}"
