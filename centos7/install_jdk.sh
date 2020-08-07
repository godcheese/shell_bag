#!/usr/bin/env bash
# encoding: utf-8.0

# http://github.com/godcheese/shell_bag
# author: godcheese [godcheese@outlook.com]
# description: Auto install JDK

# install jdk
function install_jdk() {
    echo "Installing JDK..."
    install_path=$1
    download_url=$2
    file_name=$3
    base_file_name=$(basename ${download_url})
    if [[ ${download_url} =~ ^http.* ]]; then
        sudo curl -o ${base_file_name} ${download_url}
    fi
    rm -rf ${install_path}/${file_name} && mkdir -p ${install_path}
    tar -zxvf ${base_file_name} -C ${install_path}
    rm -rf /usr/local/bin/java
    rm -rf /usr/local/bin/javac
    rm -rf /usr/local/bin/jar
    ln -fs ${install_path}/${file_name}/bin/java /usr/local/bin/java
    ln -fs ${install_path}/${file_name}/bin/javac /usr/local/bin/javac
    ln -fs ${install_path}/${file_name}/bin/jar /usr/local/bin/jar
    sed -i "/# Made for JDK/d" /etc/profile
    sed -i "/JAVA_HOME/d" /etc/profile
    sed -i "/CLASSPATH/d" /etc/profile
    sudo echo "# Made for JDK env by godcheese [godcheese@outlook.com] on $(date +%F)" >> /etc/profile
    sudo echo "export JAVA_HOME=\"${install_path}/${file_name}\"" >> /etc/profile
    sudo echo "export CLASSPATH=\".:\${JAVA_HOME}jre/lib/rt.jar:\${JAVA_HOME}/lib/dt.jar:\${JAVA_HOME}/lib/tools.jar\"" >> /etc/profile
    sudo echo "export PATH=\"\${JAVA_HOME}/bin:\${PATH}\"" >> /etc/profile
    source /etc/profile
    profile=$(tail -4 /etc/profile)
    echo -e "\033[32m
    写入 /etc/profile 的环境变量内容：
    ${profile}
    \033[0m"
    version=$(java -version 2>&1)
    if [[ ! $? == 0 ]]; then
	    echo -e "\033[31m
        JDK 安装失败！
        \033[0m"
	    exit 0
    else
        echo -e "\033[32m
        JDK 安装成功！
        \033[0m"
        echo -e "\033[32m
        - JDK 版本：${version}
        - JDK 安装路径：${install_path}/${file_name}
        \033[0m"
        exit 0
    fi
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
        install_jdk $2 $3 $4
        ;;
    "uninstall")
        uninstall_jdk $2 $3 $4
        ;;
    *)
        echo "请输入正确的命令"
        exit 0
        ;;
esac