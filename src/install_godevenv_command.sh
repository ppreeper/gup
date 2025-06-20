# gopls
echo "installing gopls"
go install golang.org/x/tools/gopls@latest

# gotests
echo "installing gotests"
go install github.com/cweill/gotests/gotests@latest

# gomodifytags
echo "installing gomodifytags"
go install github.com/fatih/gomodifytags@latest

# impl
echo "installing impl"
go install github.com/josharian/impl@latest

# goplay
echo "installing goplay"
go install github.com/haya14busa/goplay/cmd/goplay@latest

# dlv
echo "installing dlv"
go install github.com/go-delve/delve/cmd/dlv@latest

# staticcheck
echo "installing staticcheck"
go install honnef.co/go/tools/cmd/staticcheck@latest

# govulncheck
echo "installing govulncheck"
go install golang.org/x/vuln/cmd/govulncheck@latest

# air
echo "installing air"
go install github.com/air-verse/air@latest

# templ
echo "installing templ"
go install github.com/a-h/templ/cmd/templ@latest

# swag
echo "installing swag"
go install github.com/swaggo/swag/cmd/swag@latest
