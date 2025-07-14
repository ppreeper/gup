APPBIN=$(which rustup 2>/dev/null || echo "")

if [ -z "${APPBIN}" ]; then
    echo "Installing Rust"
    wget -qO- https://sh.rustup.rs | sh
else
    echo "Upgrading Rust"
    "${APPBIN}" update
    exit 0
fi
