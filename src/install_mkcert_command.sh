APP="mkcert"

sudo apt install libnss3-tools
sudo wget -O "/usr/local/bin/${APP}" "https://dl.filippo.io/mkcert/latest?for=linux/amd64"
sudo "/usr/local/bin/${APP}"
