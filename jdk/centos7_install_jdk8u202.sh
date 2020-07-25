#!/usr/bin/env bash

# http://github.com/godcheese/shell_bag
# author: godcheese [godcheese@outlook.com]

current_path=${pwd}
webwork_path=/webwork
webserver_path=${webwork_path}/webserver
temp_path=/tmp

function install_jdk() {

    echo -e "\033[32m
    -------------------------------------------------
    | Install JDK 8                                 |
    | http://github.com/godcheese/shell_bag         |
    | author: godcheese [godcheese@outlook.com]     |
    -------------------------------------------------
    \033[0m"

    download_version=jdk1.8.0_202
    download_url=https://repo.huaweicloud.com/java/jdk/8u202-b08/jdk-8u202-linux-x64.tar.gz
    install_path=${webserver_path}/jdk/jdk8
    cd ${temp_path}
    sudo mkdir -p ${install_path}
    sudo curl -o ${download_version}.tar.gz ${download_url}
    tar -xvf ${download_version}.tar.gz
    mv -f ${download_version}/* ${install_path}
    ln -sf ${install_path}/bin/java /usr/bin/java
    ln -sf ${install_path}/bin/javac /usr/bin/javac
    ln -sf ${install_path}/bin/jar /usr/bin/jar
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
cd ${current_path} && rm -rf $0