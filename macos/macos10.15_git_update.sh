#!/usr/bin/env bash

# http://github.com/godcheese/shell_bag
# author: godcheese [godcheese@outlook.com]

    echo -e "\033[32m
    -------------------------------------------------
    | macOS 10.15 Auto Install git                  |
    | http://github.com/godcheese/shell_bag         |
    -------------------------------------------------
    \033[0m"

brew --version
if [ ! $? -eq 0 ]; then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
    brew install git
fi
which git
brew link git --overwrite
git --version
if [ ! $? -eq 0 ]; then
    echo -e "\033[31m
        git 安装失败！
	    \033[0m"
	    exit
    else
        echo -e "\033[32m
        git 安装成功！
        \033[0m"
        exit
    fi