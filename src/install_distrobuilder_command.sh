PWD=$(pwd)
REPO="https://github.com/lxc/distrobuilder"
rm -rf /tmp/distrobuilder
git clone "${REPO}" /tmp/distrobuilder
cd /tmp/distrobuilder
make
cd "$PWD"
rm -rf /tmp/distrobuilder
