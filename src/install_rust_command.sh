APPBIN=$(command -v rustup 2>/dev/null || echo "")

if [ -z "${APPBIN}" ]; then
    echo "Installing Rust"

    tmp_dir=$(gup_mktemp_dir)
    trap 'rm -rf "${tmp_dir}"' RETURN

    gup_download "https://sh.rustup.rs" "${tmp_dir}/rustup-init.sh"
    sh "${tmp_dir}/rustup-init.sh" -y
else
    echo "Upgrading Rust"
    "${APPBIN}" update
    exit 0
fi
