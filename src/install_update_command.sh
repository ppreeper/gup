if [ "$(id -u)" = 0 ]; then
    IDIR="/usr/local/bin"
    sudo mkdir -p "${IDIR}"
else
    IDIR="${HOME}/.local/bin"
    mkdir -p "${IDIR}"
fi

cat <<-_EOF_ > "${IDIR}/update"
#!/bin/bash
apt update -y && apt full-upgrade -y && apt autoremove -y && apt autoclean -y
_EOF_

chmod +x "${IDIR}/update"
