#!/usr/bin/env bash
# encoding: utf-8.0

# http://github.com/godcheese/shell_bag
# author: godcheese [godcheese@outlook.com]

webwork_path=/webwork
webserver_path=/webserver
temp_path=/tmp

function install_mysql() {

    echo -e "\033[32m
    -------------------------------------------------
    | Install MySQL 5.7                             |
    | http://github.com/godcheese/shell_bag         |
    | author: godcheese [godcheese@outlook.com]     |
    -------------------------------------------------
    \033[0m"

    mysql_password=123456
    mysql_port=3306
    download_version=mysql-5.7.28-el7-x86_64
    download_url=http://mirrors.ustc.edu.cn/mysql-ftp/Downloads/MySQL-5.7/${download_version}.tar.gz
    # download_url=https://downloads.mysql.com/archives/get/p/23/file/${download_version}.tar.gz
    mysql_path=${webwork_path}${webserver_path}/mysql
    install_version=mysql57
    install_path=${mysql_path}/${install_version}
    sudo mkdir -p ${mysql_path}
    sudo mkdir -p ${mysql_path}/data/${install_version}
    sudo mkdir -p ${mysql_path}/log
    sudo curl -o ${install_path}.tar.gz ${download_url}
    tar -zxvf ${install_path}.tar.gz
    mv -f ${download_version}/* ${install_path}
    cp -f ${install_path}/support-files/mysql.server /etc/init.d/mysql
    chkconfig --add mysql
    chkconfig mysql on
    ln -s -f ${install_path}/bin/mysql /usr/bin/mysql
    ln -s -f ${install_path}/bin/mysqldump /usr/bin/mysqldump
    ln -s -f ${install_path}/bin/myisamchk /usr/bin/myisamchk
    ln -s -f ${install_path}/bin/mysqld_safe /usr/bin/mysqld_safe

    rm -rf ${mysql_path}/${install_version}.lock && sudo touch ${mysql_path}/${install_version}.sock
    rm -rf ${mysql_path}/${install_version}.pid && sudo touch ${mysql_path}/${install_version}.pid
    rm -rf ${mysql_path}/log/${install_version}-error.log && sudo touch ${mysql_path}/log/${install_version}-error.log

    rm -rf /etc/my.cnf && sudo touch /etc/my.cnf

    cat > /etc/my.cnf << EOF
[client]
socket=${mysql_path}/${install_version}.sock
[mysqld]
basedir=${install_path}
datadir=${mysql_path}/data/${install_version}
socket=${mysql_path}/${install_version}.sock
pid-file=${mysql_path}/${install_version}.pid
port=${mysql_port}
symbolic-links=0
[mysqld_safe]
log-error=${mysql_path}/log/${install_version}-error.log
pid-file=${mysql_path}/${install_version}.pid
!includedir /etc/my.cnf.d
EOF

    sudo echo " " >> /etc/profile
    sudo echo "# Made for mysql env by godcheese [godcheese@outlook.com] on $(date +%F)" >> /etc/profile
    sudo echo "export MYSQL_HOME=${install_path}" >> /etc/profile
    sudo echo "export PATH=\$MYSQL_HOME/bin:\$PATH" >> /etc/profile
    tail -4 /etc/profile
    source /etc/profile

    groupadd mysql && useradd -r -g mysql mysql
    chown -R mysql ${mysql_path}
    ${install_path}/bin/mysqld --initialize-insecure --user=mysql
    service mysql restart
    ${install_path}/bin/mysqladmin -u root password "${mysql_password}"
     mysql --version
     version=$1
    if [[ ! $? == 0 ]]; then
	    echo -e "\033[31m
	    MySQL 安装失败！
	    \033[0m"
	    exit
    else
        echo -e "\033[32m
        MySQL 安装成功！
        \033[0m"
        echo -e "\033[32m
        - MySQL 版本：${version}
        - MySQL 安装路径：${install_path}
        - MySQL Data 路径：${mysql_path}/data/${install_version}
        - MySQL 端口：${mysql_port}
        - root 密码：${mysql_password}
        \033[0m"
        exit
    fi
}

install_mysql