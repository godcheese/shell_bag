#!/usr/bin/env bash

# http://github.com/godcheese/shell_bag
# author: godcheese [godcheese@outlook.com]

webwork_path=/webwork
temp_path=/tmp

echo whoami
function install_jdk8() {
    if [[ whoami != "root" ]]; then
        echo -e "\033[31m 这个脚本必须用root执行！ \033[0m"
        exit
    fi

    echo -e "\033[32m
    -------------------------------------------------
    | CentOS 7 Auto Install Jdk 8                   |
    | http://github.com/godcheese/shell_bag         |
    -------------------------------------------------
    \033[0m"

    jdk_path=${webwork_path}/jdk
    install_version=jdk8
    install_path=${jdk_path}/${install_version}
    download_version=jdk1.8.0_202
    download_url=https://repo.huaweicloud.com/java/jdk/8u202-b08/jdk-8u202-linux-x64.tar.gz
    cd ${temp_path}
    wget -O ${download_version}.tar.gz ${download_url}
    tar -zxvf ${download_version}.tar.gz
    mkdir -p ${install_path}
    mv -f ${download_version}/* ${install_path}
    ln -s ${install_path}/bin/java /usr/bin/java
    ln -s ${install_path}/bin/javac /usr/bin/javac
    ln -s ${install_path}/bin/jar /usr/bin/jar

    echo " " >> /etc/profile
    echo "# Made for jdk env by godcheese on $(date +%F)" >> /etc/profile
    echo "export JAVA_HOME=${install_path}" >> /etc/profile
    echo "export CLASSPATH=.:\$JAVA_HOME/jre/lib/rt.jar:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar" >> /etc/profile
    echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /etc/profile
    tail -4 /etc/profile
    source /etc/profile
    java -version
    if [[ ! $? -eq 0 ]]; then
	    echo -e "\033[31m
        Jdk 安装失败！
        \033[0m"
	    exit
    else
        echo -e "\033[32m
        Jdk 安装成功！
        \033[0m"
        echo -e "\033[32m
        - Jdk 安装路径：${install_path}
        \033[0m"
        exit
    fi

}

install_jdk8