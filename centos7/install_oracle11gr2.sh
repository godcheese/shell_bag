#!/usr/bin/env bash
# encoding: utf-8.0

# http://github.com/godcheese/shell_bag
# author: godcheese [godcheese@outlook.com]
# description: Install Oracle 11G r2

# install oracle11gr2
function install_oracle11gr2() {
    echo "Installing Oracle 11G r2..."
    echo "nothing."
}

# show banner
function show_banner() {
   echo -e "\033[32m
    -------------------------------------------------
    | Install for CentOS                            |
    | http://github.com/godcheese/shell_bag         |
    | author: godcheese [godcheese@outlook.com]     |
    -------------------------------------------------
    \033[0m"
}


show_banner
case "$1" in
    "install")
        install_oracle11gr2 $2 $3 $4
        ;;
    "uninstall")
        uninstall_oracle11gr2 $2 $3 $4
        ;;
    *)
        echo "请输入正确的命令"
        exit 0
        ;;
esac