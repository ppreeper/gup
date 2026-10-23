set -eu

APP="present"
REPO="ppreeper/present"
vers=$(gup_get_latest_release "${REPO}")

gup_ensure_go
go install github.com/${REPO}/cmd/present@"${vers}"