#!/usr/bin/env bash
# encoding: utf-8.0

# http://github.com/godcheese/shell_bag
# author: godcheese [godcheese@outlook.com]
# description: Auto install Redis

# install redis
function install_redis() {
      echo "Installing Redis..."

#     if test -r /etc/init.d/redisd; then
#         service redisd stop
#     else
#         if test -r /usr/local/bin/redisd; then
#             nginx -s stop
#         fi
#     fi
    current_path=$(pwd)
    yum install -y gcc make
#     yum install -y centos-release-scl
#     yum install -y devtoolset-9-gcc devtoolset-9-gcc-c++ devtoolset-9-binutils
#     scl enable devtoolset-9 bash
#     yum install -y zlib*
#     yum install -y pcre-devel
    install_path=$1
    download_url=$2
    file_name=$3
    base_file_name=$(basename ${download_url})
    if [[ ${download_url} =~ ^http.* ]]; then
        curl -o ${base_file_name} ${download_url}
    fi
    rm -rf ${install_path}/${file_name} && mkdir -p ${install_path}
    tar -zxvf ${base_file_name} -C ${install_path}

    cd ${install_path}/${file_name}
    make distclean
    make MALLOC=libc
    cd ${install_path}/${file_name}/src
    make && make install
    cd ${current_path}
#     if test -r /usr/local/bin/redis-server; then
#         result=$(ps -ef | grep redis | grep -v grep)
#         if [[ ${result} =~ "00:00:00 nginx" ]]; then
#             nginx -s stop
#         fi
#     fi
    rm -rf /usr/local/bin/redis-server
    rm -rf /usr/local/bin/redis-cli
    ln -fs ${install_path}/${file_name}/src/redis-server /usr/local/bin/redis-server
    ln -fs ${install_path}/${file_name}}/src/redis-cli /usr/local/bin/redis-cli
#     rm -rf ${install_path}/${file_name}/bin/nginx.service && touch ${install_path}/${file_name}/bin/nginx.service

#     rm -rf /etc/init.d/nginx
#     \cp -rf ${install_path}/${file_name}/bin/nginx.service /etc/init.d/nginx

#     chmod 755 /etc/init.d/nginx
#     chkconfig --add nginx && chkconfig nginx on
    ${install_path}/${file_name}/utils/install_server.sh
    sed -i "/# Made for Redis/d" /etc/profile
    sed -i "/REDIS_HOME/d" /etc/profile
    echo "# Made for Redis env by godcheese [godcheese@outlook.com] on $(date +%F)" >> /etc/profile
    echo "export REDIS_HOME=\"${install_path}/${file_name}\"" >> /etc/profile
    echo "export PATH=\"\${REDIS_HOME}/src:\${PATH}\"" >> /etc/profile
    source /etc/profile
    profile=$(tail -4 /etc/profile)
    echo -e "\033[32m
    写入 /etc/profile 的环境变量内容：
    ${profile}
    \033[0m"
    version=$(redis-server --version 2>&1)
    if [[ ! $? == 0 ]]; then
	    echo -e "\033[31m
        Redis 安装失败！
        \033[0m"
	    exit 0
    else
        firewall-cmd --zone=public --add-port=6379/tcp --permanent > /dev/null 2>&1
        firewall-cmd --reload > /dev/null 2>&1
        echo -e "\033[32m
        Redis 安装成功！
        \033[0m"
        echo -e "\033[32m
        - Redis 版本：${version}
        - Redis 安装路径：${install_path}/${file_name}/bin
        - Redis 配置文件路径：/etc/redis/6379.conf
        - Redis 常用命令：
          状态：service redis status
          启动：service redis start
          停止：service redis stop
          重启：service redis restart
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
        install_python3 $2 $3 $4
        ;;
    "uninstall")
        uninstall_python3 $2 $3 $4
        ;;
    *)
        echo "请输入正确的命令"
        exit 0
        ;;
esac