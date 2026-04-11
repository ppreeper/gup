APP="s5cmd"
REPO="peak/s5cmd"
vers=$(gup_get_latest_release "${REPO}")

go install github.com/peak/s5cmd/v2@${vers}