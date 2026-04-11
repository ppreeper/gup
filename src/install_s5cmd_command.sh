APP="s5cmd"
REPO="peak/s5cmd"
RURL="https://api.github.com/repos/${REPO}/releases/latest"
vers=$(wget -qO- "${RURL}" | jq .tag_name | tr -d '"')

go install github.com/peak/s5cmd/v2@${vers}