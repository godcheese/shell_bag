#!/usr/bin/env bash
# encoding: utf-8.0

# http://github.com/godcheese/shell_bag
# author: godcheese [godcheese@outlook.com]

webwork_path=/Volumes/office/GodcheeseWork/dev/webwork
webserver_path=/webserver
temp_path=/tmp

function install_nginx() {

    download_version=nginx-1.18.0
    download_url=http://nginx.org/download/${download_version}.tar.gz
    nginx_path=${webwork_path}${webserver_path}/nginx
    install_version=${download_version}
    install_path=${nginx_path}/${download_version}
    sudo mkdir -p ${nginx_path}
    sudo curl -o ${install_path}.tar.gz ${download_url}
    tar -zxvf ${install_path}.tar.gz -C ${nginx_path}
    cd ${install_path}
    bin_path=`pwd`/bin
    conf_path=${bin_path}/conf/nginx.conf
    logs_path=${bin_path}/logs
    configure --prefix=${bin_path} --sbin-path=nginx --conf-path=${conf_path} --pid-path=${logs_path}/nginx.pid
    make && make install
    #make all && make install
   # make clean && make distclean
    cd ${bin_path}
    nginx -v
    echo $?
    version=$?
    if [[ ! $? -eq 0 ]]; then
        echo -e "\033[31m
        Nginx 安装失败！
	    \033[0m"
	    exit
    else
        echo -e "\033[32m
        Nginx 安装成功！
        \033[0m"
        echo -e "\033[32m
        - Nginx 版本：${version}
        - Nginx 安装路径：${install_path}
        - Nginx bin 路径：${bin_path}
        - Nginx 配置文件路径：${conf_path}
        - Nginx 日志路径：${logs_path}
        \033[0m"
        exit
    fi
}

install_nginx