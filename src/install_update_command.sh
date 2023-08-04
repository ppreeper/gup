cat <<-_EOF_ | sudo tee /usr/local/bin/update > /dev/null
#!/bin/bash
sudo bash -c "apt update -y && apt full-upgrade -y && apt autoremove -y && apt autoclean -y"
_EOF_

sudo chmod +x /usr/local/bin/update