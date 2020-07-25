#!/usr/bin/env bash

# http://github.com/godcheese/shell_bag
# author: godcheese [godcheese@outlook.com]

webwork_path=/webwork
webserver_path=/webserver
temp_path=/tmp

function install_maven() {

    echo -e "\033[32m
    -------------------------------------------------
    | Install Maven 3                               |
    | http://github.com/godcheese/shell_bag         |
    | author: godcheese [godcheese@outlook.com]     |
    -------------------------------------------------
    \033[0m"

    download_version=apache-maven-3.6.3-bin
    download_url=https://mirrors.tuna.tsinghua.edu.cn/apache/maven/maven-3/3.6.3/binaries/${download_version}.tar.gz
    maven_path=${webwork_path}${webserver_path}/maven
    install_version=maven3
    install_path=${maven_path}/${install_version}
    curl -o ${install_path}.tar.gz ${download_url}
    tar -zxvf ${install_path}.tar.gz
    sudo mkdir -p ${install_path}
    mv -f ${download_version}/* ${install_path}
    ln -s ${install_path}/bin/mvn /usr/bin/mvn

    sudo echo " " >> /etc/profile
    sudo echo "# Made for maven env by godcheese on $(date +%F)" >> /etc/profile
    sudo echo "export M2_HOME=${install_path}" >> /etc/profile
    sudo echo "export PATH=\$M2_HOME/bin:\$PATH" >> /etc/profile
    tail -4 /etc/profile
    source /etc/profile
    mvn --version
    version=$1
    if [[ ! $? == 0 ]]; then
	    echo -e "\033[31m
	    Maven 安装失败！
	    \033[0m"
	    exit
    else
        echo -e "\033[32m
        Maven 安装成功！
        \033[0m"
        echo -e "\033[32m
        - Maven 版本：${version}
        - Maven 安装路径：${install_path}
        \033[0m"
        exit
    fi
}

install_maven