APP="gotests"
REPO="cweill/gotests"
vers=$(gup_get_latest_release "${REPO}")

gup_ensure_go
go install github.com/cweill/gotests/gotests@${vers}
