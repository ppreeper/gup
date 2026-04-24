set -euo pipefail

APP="goimports"
REPO="golang/tools"

gup_ensure_go
go install golang.org/x/tools/cmd/goimports@latest