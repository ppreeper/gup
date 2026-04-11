APP="golangci-lint"
REPO="golangci/golangci-lint"
RURL="https://api.github.com/repos/${REPO}/releases/latest"
vers=$(wget -qO- "${RURL}" | jq .tag_name | tr -d '"')

go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@${vers}