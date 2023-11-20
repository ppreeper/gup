KEYDIR="/etc/apt/trusted.gpg.d"
ID=$(grep -e "^ID=" /etc/os-release | cut -d "=" -f 2)
VERSION_CODENAME=$(grep ^VERSION_CODENAME /etc/os-release | cut -d "=" -f 2)
VERSION_ID=$(grep ^VERSION_ID /etc/os-release | cut -d "=" -f 2)
DEBIAN_CODENAME=$(grep ^DEBIAN_CODENAME /etc/os-release | cut -d "=" -f 2)
UBUNTU_CODENAME=$(grep ^UBUNTU_CODENAME /etc/os-release | cut -d "=" -f 2)
RELEASE=""

if [ "${ID}" == "linuxmint" ]; then
  if [ "${DEBIAN_CODENAME}" == "bookworm" ]; then
    RELEASE="Debian_Testing"
  elif [ "${UBUNTU_CODENAME}" == "jammy" ]; then
    RELEASE="xUbuntu_22.04"
  fi
elif [ "${ID}" == "debian" ]; then
  RELEASE="Debian_Testing"
elif [ "${ID}" == "ubuntu" ]; then
  RELEASE="xUbuntu_22.04"
fi

RELEASE_KEY="https://download.opensuse.org/repositories/devel:kubic:libcontainers:unstable/${RELEASE}/Release.key"

# Install Podman Repo
curl -fsSL "${RELEASE_KEY}" | gpg --dearmor | sudo tee ${KEYDIR}/devel_kubic_libcontainers_unstable.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=${KEYDIR}/devel_kubic_libcontainers_unstable.gpg] https://download.opensuse.org/repositories/devel:kubic:libcontainers:unstable/${RELEASE}/ /" \
  | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:unstable.list > /dev/null

# Install Podman
sudo bash -c "apt-get update -y && sudo apt-get install -y podman"
