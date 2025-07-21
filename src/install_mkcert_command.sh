APP="mkcert"

sudo apt update -y && \
sudo apt install -y libnss3-tools && \
sudo wget -O "/usr/local/bin/${APP}" "https://dl.filippo.io/mkcert/latest?for=linux/amd64" && \
sudo chmod +x "/usr/local/bin/${APP}"
