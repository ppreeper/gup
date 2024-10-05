#!/usr/bin/env python3
"""github app installer"""
import argparse
import subprocess
import sys

app_installer = {
    "nvim": {
        "app": "nvim",
        "repo": "https://github.com/neovim/neovim",
    }
}
app_remover = {
    "nvim": {
        "app": "nvim",
    }
}
app_service = {
    "nvim": {
        "service": "nvim",
    }
}
# APP="nvim"
# REPO="https://github.com/neovim/neovim"
# vers=$(git ls-remote --tags ${REPO} | grep "refs/tags.*[0-9]$" | awk '{print $2}' | sed 's/refs\/tags\///g' | sort -V | uniq | tail -1)

# IDIR=${HOME}/.local/nvim
# BDIR=${HOME}/.local/bin


def get_app_list():
    """return a list of applications"""
    return app_installer.keys()


def install(app: str):
    """install an application"""
    print(f"app {app}")
    print(f"repo {app_installer[app]}")
    git_ls = f"git ls-remove --tags {app_installer[app]['repo']}"
    print(git_ls)
    # r = subprocess.run(git_ls, shell=True, check=True, stdout=subprocess.PIPE)
    # if r.returncode != 0:
    #     raise OSError(f"could not install {app}")
    print("installing an application")


def remove():
    """remove an application and settings"""
    print("removing an application and settings")


def systemd():
    """install systemd service"""
    print("installing systemd service")


class ArgParser(argparse.ArgumentParser):
    """ArgParser modified to output help on error"""

    def error(self, message: str):
        print(f"error: {message}\n")
        self.print_help()


def arg_parser():
    """return an argument parser"""
    parser = ArgParser(
        prog="gup",
        description="gup - github app installer",
        epilog="thanks for using %(prog)s!",
    )
    subparsers = parser.add_subparsers(
        dest="command", title="commands", help="commands"
    )
    # install
    install_parser = subparsers.add_parser("install", help="install an application")
    install_parser.add_argument(
        "app", type=str, help="application to install", choices=app_installer.keys()
    )
    # remove
    remove_parser = subparsers.add_parser(
        "remove", help="remove an application and settings"
    )
    remove_parser.add_argument(
        "app", type=str, help="application to remove", choices=app_remover.keys()
    )
    # systemd
    systemd_parser = subparsers.add_parser("systemd", help="install systemd service")
    systemd_parser.add_argument(
        "service", type=str, help="service to install", choices=app_service.keys()
    )
    # version
    parser.add_argument(
        "--version",
        "-v",
        action="version",
        version="%(prog)s 0.0.1",
        help="show version",
    )
    return parser


def main():
    """github app installer"""
    parser = arg_parser()
    args = parser.parse_args(args=None if sys.argv[1:] else ["--help"])

    if args.command == "install":
        install(args.app)
    elif args.command == "remove":
        remove()
    elif args.command == "systemd":
        systemd()
    else:
        parser.print_help()


"""
gup - github app installer

Usage:
  gup COMMAND
  gup [COMMAND] --help | -h
  gup --version | -v

Commands:
  install   install an application
  remove    remove an application and settings
  systemd   install systemd service
"""

if __name__ == "__main__":
    main()
