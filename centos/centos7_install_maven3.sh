#!/usr/bin/env bash

# http://github.com/godcheese/shell_bag
# author: godcheese [godcheese@outlook.com]

webwork_path=/webwork
temp_path=/tmp

function install_maven3() {
    if [[ whoami != "root" ]]; then
        echo -e "\033[31m 这个脚本必须用root执行！ \033[0m"
        exit
    fi

    echo -e "\033[32m
    -------------------------------------------------
    | CentOS 7 Auto Install Maven 3                 |
    | http://github.com/godcheese/shell_bag         |
    -------------------------------------------------
    \033[0m"

    maven_path=${webwork_path}/maven
    install_version=maven3
    install_path=${maven_path}/${install_version}
    download_version=apache-maven-3.6.3
    download_url=https://mirrors.tuna.tsinghua.edu.cn/apache/maven/maven-3/3.6.3/binaries/${download_version}-bin.tar.gz
    cd ${temp_path}
    wget -O ${download_version}.tar.gz ${download_url}
    tar -zxvf ${download_version}.tar.gz
    mkdir -p ${install_path}
    mv -f ${download_version}/* ${install_path}
    ln -s ${install_path}/bin/mvn /usr/bin/mvn

    echo " " >> /etc/profile
    echo "# Made for maven env by godcheese on $(date +%F)" >> /etc/profile
    echo "export M2_HOME=${install_path}" >> /etc/profile
    echo "export PATH=\$M2_HOME/bin:\$PATH" >> /etc/profile
    tail -4 /etc/profile
    source /etc/profile
    mvn --version
    if [[ ! $? -eq 0 ]]; then
	    echo -e "\033[31m
	    Maven 安装失败！
	    \033[0m"
	    exit
    else
        echo -e "\033[32m
        Maven 安装成功！
        \033[0m"
        echo -e "\033[32m
        - Maven 安装路径：${install_path}
        \033[0m"
        exit
    fi

}

install_maven3