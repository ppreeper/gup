set -eu

APP="gopls"
REPO="golang/tools"
# vers=$(gup_get_latest_release "${REPO}")
vers="latest"

gup_ensure_go
go install golang.org/x/tools/gopls@"${vers}"
