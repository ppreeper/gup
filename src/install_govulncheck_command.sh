APP="govulncheck"
REPO="golang/vuln"
vers=$(gup_get_latest_release "${REPO}")

gup_ensure_go
go install golang.org/x/vuln/cmd/govulncheck@${vers}
