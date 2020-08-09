#!/usr/bin/env bash
# encoding: utf-8.0

# http://github.com/godcheese/shell_bag
# author: godcheese [godcheese@outlook.com]
# description: Install Maven

# install maven
function install_maven() {
    echo "Installing Maven..."
    install_path=$1
    download_url=$2
    file_name=$3
    base_file_name=$(basename ${download_url})
    if [[ ${download_url} =~ ^http.* ]]; then
        curl -o ${base_file_name} ${download_url}
    fi
    rm -rf ${install_path}/${file_name} && mkdir -p ${install_path}
    tar -zxvf ${base_file_name} -C ${install_path}
    rm -rf /usr/local/bin/mvn
    ln -fs ${install_path}/${file_name}/bin/mvn /usr/local/bin/mvn
    sed -i "/# Made for Maven/d" /etc/profile
    sed -i "/MAVEN_HOME/d" /etc/profile
    echo "# Made for Maven env by godcheese [godcheese@outlook.com] on $(date +%F)" >> /etc/profile
    echo "export MAVEN_HOME=\"${install_path}/${file_name}\"" >> /etc/profile
    echo "export PATH=\"\${MAVEN_HOME}/bin:\${PATH}\"" >> /etc/profile
    source /etc/profile
    profile=$(tail -4 /etc/profile)
    echo -e "\033[32m
    写入 /etc/profile 的环境变量内容：
    ${profile}
    \033[0m"
    version=$(mvn --version 2>&1)
    if [[ ! $? == 0 ]]; then
	    echo -e "\033[31m
        Maven 安装失败！
        \033[0m"
	    exit 0
    else
        echo -e "\033[32m
        Maven 安装成功！
        \033[0m"
        echo -e "\033[32m
        - Maven 版本：${version}
        - Maven 安装路径：${install_path}/${file_name}
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
        install_maven $2 $3 $4
        ;;
    "uninstall")
        uninstall_maven $2 $3 $4
        ;;
    *)
        echo "请输入正确的命令"
        exit 0
        ;;
esac