#!/usr/bin/env bash
# encoding: utf-8.0

# http://github.com/godcheese/shell_bag
# author: godcheese [godcheese@outlook.com]

function install_jdk() {

    echo -e "\033[32m
    -------------------------------------------------
    | Install JDK 8                                 |
    | http://github.com/godcheese/shell_bag         |
    | author: godcheese [godcheese@outlook.com]     |
    -------------------------------------------------
    \033[0m"
    install_path=$1
    download_url=$2
    file_name=$3
    sudo curl -o $(basename ${download_url}) ${download_url}
    tar -zxvf $(basename ${download_url}) -C ${install_path}
    ln -fs ${install_path}/bin/java /usr/bin/java
    ln -fs ${install_path}/bin/javac /usr/bin/javac
    ln -fs ${install_path}/bin/jar /usr/bin/jar
    sudo echo " " >> /etc/profile
    sudo echo "# Made for JDK env by godcheese [godcheese@outlook.com] on $(date +%F)" >> /etc/profile
    sudo echo "export JAVA_HOME=${install_path}" >> /etc/profile
    sudo echo "export CLASSPATH=.:\$JAVA_HOME/jre/lib/rt.jar:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar" >> /etc/profile
    sudo echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /etc/profile
    tail -4 /etc/profile
    source /etc/profile
    java -version
    version=$1
    if [[ ! $? == 0 ]]; then
	    echo -e "\033[31m
        JDK 安装失败！
        \033[0m"
	    exit
    else
        echo -e "\033[32m
        JDK 安装成功！
        \033[0m"
        echo -e "\033[32m
        - JDK 版本：${version}
        - JDK 安装路径：${install_path}
        \033[0m"
        exit
    fi
}

install_jdk