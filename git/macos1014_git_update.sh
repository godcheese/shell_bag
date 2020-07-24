#!/usr/bin/env bash

# http://github.com/godcheese/shell_bag
# author: godcheese [godcheese@outlook.com]

function git_update() {
    echo -e "\033[32m
    -------------------------------------------------
    | Install Git                                   |
    | http://github.com/godcheese/shell_bag         |
    | author: godcheese [godcheese@outlook.com]     |
    -------------------------------------------------
    \033[0m"

    brew --version
   if [[ ! $? -eq 0 ]]; then
      /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
   else
      brew update
      brew install git
   fi
   which git
   brew link git --overwrite
   git --version
  version=`git --version| grep git`
  echo ${version}
   if [[ ! $? -eq 0 ]]; then
        echo -e "\033[31m
        Git 安装失败！
	    \033[0m"
	    exit
   else
        echo -e "\033[32m
        Git 安装成功！
        \033[0m"
        echo -e "\033[32m
        - Git 版本：${version}
        \033[0m"
        exit
   fi
}

git_update