set -eu

APP="yamlfmt"
REPO="google/yamlfmt"
vers=$(gup_get_latest_release "${REPO}")

gup_ensure_go
go install github.com/${REPO}/cmd/yamlfmt@"${vers}"