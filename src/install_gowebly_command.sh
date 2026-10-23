set -eu

APP="gowebly"
REPO="gowebly/gowebly"
vers=$(gup_get_latest_release "${REPO}")

gup_ensure_go
go install github.com/${REPO}/v2@"${vers}"