set -eu

APP="sshconfig"
REPO="ppreeper/sshconfig"
vers=$(gup_get_latest_release "${REPO}")

gup_ensure_go
go install github.com/${REPO}@"${vers}"
