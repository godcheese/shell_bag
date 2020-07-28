#!/usr/bin/env bash
# encoding: utf-8.0

# http://github.com/godcheese/shell_bag
# author: godcheese [godcheese@outlook.com]

function install_jdk() {

    echo -e "\033[32m
    -------------------------------------------------
    | Install   for CentOS                          |
    | http://github.com/godcheese/shell_bag         |
    | author: godcheese [godcheese@outlook.com]     |
    -------------------------------------------------
    \033[0m"
    install_path=$1
    download_url=$2
    file_name=$3
    base_file_name=$(basename ${download_url})
    sudo curl -o ${base_file_name} ${download_url}
    mkdir -p ${install_path}
    tar -zxvf ${base_file_name} -C ${install_path}
    echo ${install_path}/${file_name}
    rm -rf /usr/bin/java
    rm -rf /usr/bin/javac
    rm -rf /usr/bin/jar
    ln -fs ${install_path}/${file_name}/bin/java /usr/bin/java
    ln -fs ${install_path}/${file_name}/bin/javac /usr/bin/javac
    ln -fs ${install_path}/${file_name}/bin/jar /usr/bin/jar
    sudo echo " " >> /etc/profile
    sudo echo "# Made for JDK env by godcheese [godcheese@outlook.com] on $(date +%F)" >> /etc/profile
    sudo echo "export JAVA_HOME=${install_path}/${file_name}" >> /etc/profile
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
        - JDK 安装路径：${install_path}/${file_name}
        \033[0m"
        exit
    fi
}

if [[ $1x == 'jdk'x ]];then
    install_jdk $2 $3 $4
elif [[ $1x == 'python'x ]];then
    echo 'python'
elif [[ $1x == 'maven'x ]];then
    echo 'maven'
elif [[ $1x == 'nginx'x ]];then
    echo 'nginx'
elif [[ $1x == 'mysql'x ]];then
    echo 'mysql'
elif [[ $1x == 'oracle'x ]];then
    echo 'oracle'
else
    echo '请选择安装项'
fi

