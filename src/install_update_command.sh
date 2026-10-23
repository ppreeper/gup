set -eu

if [ "$(id -u)" = 0 ]; then
    IDIR="/usr/local/bin"
    mkdir -p "${IDIR}"
else
    IDIR="${HOME}/.local/bin"
    mkdir -p "${IDIR}"
fi

printf '%s\n' \
    '#!/usr/bin/env sh' \
    'sudo sh -c "apt update -y && apt full-upgrade -y && apt autoremove -y && apt autoclean -y"' \
    '' \
    '# flatpak' \
    'if command -v flatpak >/dev/null 2>&1; then' \
    '	flatpak update' \
    'fi' > "${IDIR}/update"

chmod +x "${IDIR}/update"
