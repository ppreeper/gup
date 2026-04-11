APP="timer"
REPO="caarlos0/timer"
vers=$(gup_get_latest_release "${REPO}")

gup_ensure_go
go install github.com/caarlos0/timer@${vers}