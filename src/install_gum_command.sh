APP="gum"
REPO="charmbracelet/gum"
vers=$(gup_get_latest_release "${REPO}")

gup_ensure_go
go install github.com/charmbracelet/gum@${vers}