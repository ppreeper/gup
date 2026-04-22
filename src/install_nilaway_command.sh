set -euo pipefail

APP="nilaway"
REPO="uber-go/nilaway"
vers=$(gup_get_latest_release "${REPO}")

gup_ensure_go
go install go.uber.org/nilaway/cmd/nilaway@"${vers}"