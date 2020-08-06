#!/usr/bin/env bash
# encoding: utf-8.0

# http://github.com/godcheese/shell_bag
# author: godcheese [godcheese@outlook.com]

function show_banner() {
   echo -e "\033[32m
    -------------------------------------------------
    | Install for CentOS                            |
    | http://github.com/godcheese/shell_bag         |
    | author: godcheese [godcheese@outlook.com]     |
    -------------------------------------------------
    \033[0m"
}

function install_jdk() {
    install_path=$1
    download_url=$2
    file_name=$3
    base_file_name=$(basename ${download_url})
    if [[ ${download_url} =~ ^http.* ]]; then
        sudo curl -o ${base_file_name} ${download_url}
    fi
    rm -rf ${install_path}/${file_name} && mkdir -p ${install_path}
    tar -zxvf ${base_file_name} -C ${install_path}
    rm -rf /usr/bin/java
    rm -rf /usr/bin/javac
    rm -rf /usr/bin/jar
    ln -fs ${install_path}/${file_name}/bin/java /usr/bin/java
    ln -fs ${install_path}/${file_name}/bin/javac /usr/bin/javac
    ln -fs ${install_path}/${file_name}/bin/jar /usr/bin/jar
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

function install_python3() {
    current_path=$(pwd)
    yum install -y gcc
    yum install -y zlib*
    install_path=$1
    download_url=$2
    file_name=$3
    base_file_name=$(basename ${download_url})
    if [[ ${download_url} =~ ^http.* ]]; then
        sudo curl -o ${base_file_name} ${download_url}
    fi
    rm -rf ${install_path}/${file_name} && mkdir -p ${install_path}
    tar -zxvf ${base_file_name} -C ${install_path}
    cd ${install_path}/${file_name}
    ./configure --prefix=${install_path}/${file_name}  --with-ssl
    make && make install
    cd ${current_path}
    rm -rf /usr/bin/pip3
    rm -rf /usr/bin/python3
    ln -fs ${install_path}/${file_name}/bin/python3 /usr/bin/python3
    ln -fs ${install_path}/${file_name}/bin/pip3 /usr/bin/pip3
    sed -i "/# Made for Python/d" /etc/profile
    sed -i "/PYTHON_HOME/d" /etc/profile
    sudo echo "# Made for Python env by godcheese [godcheese@outlook.com] on $(date +%F)" >> /etc/profile
    sudo echo "export PYTHON_HOME=\"${install_path}/${file_name}\"" >> /etc/profile
    sudo echo "export PATH=\"\${PYTHON_HOME}/bin:\${PATH}\"" >> /etc/profile
    source /etc/profile
    profile=$(tail -4 /etc/profile)
    echo -e "\033[32m
    写入 /etc/profile 的环境变量内容：
    ${profile}
    \033[0m"
    version1=$(python3 --version 2>&1)
    version2=$(pip3 --version 2>&1)
    if [[ ! $? == 0 ]]; then
	    echo -e "\033[31m
        Python 安装失败！
        \033[0m"
	    exit 0
    else
        echo -e "\033[32m
        Python 安装成功！
        \033[0m"
        echo -e "\033[32m
        - Python 版本：${version1}
        - Pip 版本：${version2}
        - Python 安装路径：${install_path}/${file_name}
        \033[0m"
        exit 0
    fi
}

function install_maven() {
    install_path=$1
    download_url=$2
    file_name=$3
    base_file_name=$(basename ${download_url})
    if [[ ${download_url} =~ ^http.* ]]; then
        sudo curl -o ${base_file_name} ${download_url}
    fi
    rm -rf ${install_path}/${file_name} && mkdir -p ${install_path}
    tar -zxvf ${base_file_name} -C ${install_path}
    rm -rf /usr/bin/mvn
    ln -fs ${install_path}/${file_name}/bin/mvn /usr/bin/mvn
    sed -i "/# Made for Maven/d" /etc/profile
    sed -i "/MAVEN_HOME/d" /etc/profile
    sudo echo "# Made for Maven env by godcheese [godcheese@outlook.com] on $(date +%F)" >> /etc/profile
    sudo echo "export MAVEN_HOME=\"${install_path}/${file_name}\"" >> /etc/profile
    sudo echo "export PATH=\"\${MAVEN_HOME}/bin:\${PATH}\"" >> /etc/profile
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

function install_nginx() {
    if test -r /etc/init.d/nginx; then
        service nginx stop
    else
        if test -r /usr/bin/nginx; then
            nginx -s stop
        fi
    fi
    current_path=$(pwd)
    yum install -y gcc
    yum install -y zlib*
    yum install -y pcre-devel
    install_path=$1
    download_url=$2
    file_name=$3
    base_file_name=$(basename ${download_url})
    if [[ ${download_url} =~ ^http.* ]]; then
        sudo curl -o ${base_file_name} ${download_url}
    fi
    rm -rf ${install_path}/${file_name} && mkdir -p ${install_path}
    tar -zxvf ${base_file_name} -C ${install_path}
    mkdir -p ${install_path}
    cd ${install_path}/${file_name}
    ./configure --prefix=${install_path}/${file_name}/bin  --sbin-path=nginx --conf-path=${install_path}/${file_name}/bin/conf/nginx.conf --pid-path=${install_path}/${file_name}/bin/logs/nginx.pid
#     sudo touch ${install_path}/${file_name}/bin/logs/nginx.pid

    make && make install
    cd ${current_path}
    if test -r /usr/bin/nginx; then
        result=$(ps -ef | grep nginx | grep -v grep)
        if [[ ${result} =~ "00:00:00 nginx" ]]; then
            nginx -s stop
        fi
    fi
    rm -rf /usr/bin/nginx
    ln -fs ${install_path}/${file_name}/bin/nginx /usr/bin/nginx
    rm -rf ${install_path}/${file_name}/bin/nginx.service && sudo touch ${install_path}/${file_name}/bin/nginx.service
    cat > ${install_path}/${file_name}/bin/nginx.service << EOF
#!/bin/sh
# chkconfig: - 85 15
# description: Nginx is a World Wide Web server. It is used to serve.
# author: godcheese [godcheese@outlook.com]
bin_path=
if test -z "\${bin_path}" ; then
    bin_path="/usr/bin/nginx"
fi
if ! test -r "\${bin_path}" ; then
    echo "Nginx not found:\${bin_path}"
    exit 0
fi
case "\$1" in
    "status")
        result=\$(ps -ef | grep nginx | grep -v grep)
        if [[ \${result} =~ "00:00:00 nginx" ]]; then
            echo "Nginx is running."
        else
            echo "Nginx is not running."
        fi
        ;;
    "start")
        result=\$(ps -ef | grep nginx | grep -v grep)
        if [[ \${result} =~ "00:00:00 nginx" ]]; then
            echo "Nginx is running."
        else
            echo "Starting nginx..."
            "\${bin_path}"
            echo "Nginx start successful."
        fi
        ;;
    "stop")
        result=\$(ps -ef | grep nginx | grep -v grep)
        if [[ \${result} =~ "00:00:00 nginx" ]]; then
            echo "Stopping nginx..."
            "\${bin_path}" -s stop
            echo "Nginx stop successful."
        else
            echo "Nginx is not running."
        fi
        ;;
    "restart")
        result=\$(ps -ef | grep nginx | grep -v grep)
        echo "Restarting nginx..."
        if [[ \${result} =~ "00:00:00 nginx" ]]; then
            "\${bin_path}" -s reload
        else
            "\${bin_path}"
            "\${bin_path}" -s reload
        fi
        echo "Nginx restart successful."
        ;;
    "test")
        echo "Testing nginx conf..."
        "\${bin_path}" -t
        echo "Nginx conf test successful."
        ;;
esac
EOF

    rm -rf /etc/init.d/nginx
    \cp -rf ${install_path}/${file_name}/bin/nginx.service /etc/init.d/nginx
    chmod 755 /etc/init.d/nginx
    chkconfig --add nginx && chkconfig nginx on
    sed -i "/# Made for Nginx/d" /etc/profile
    sed -i "/NGINX_HOME/d" /etc/profile
    sudo echo "# Made for Nginx env by godcheese [godcheese@outlook.com] on $(date +%F)" >> /etc/profile
    sudo echo "export NGINX_HOME=\"${install_path}/${file_name}/bin\"" >> /etc/profile
    sudo echo "export PATH=\"\${NGINX_HOME}:\${PATH}\"" >> /etc/profile
    source /etc/profile
    profile=$(tail -4 /etc/profile)
    echo -e "\033[32m
    写入 /etc/profile 的环境变量内容：
    ${profile}
    \033[0m"
    service nginx restart
    version=$(nginx -v 2>&1)
    if [[ ! $? == 0 ]]; then
	    echo -e "\033[31m
        Nginx 安装失败！
        \033[0m"
	    exit 0
    else
        firewall-cmd --zone=public --add-service=http --permanent > /dev/null 2>&1
        firewall-cmd --zone=public --add-service=https --permanent > /dev/null 2>&1
        firewall-cmd --zone=public --add-port=80/tcp --permanent > /dev/null 2>&1
        firewall-cmd --zone=public --add-port=443/tcp --permanent > /dev/null 2>&1
        firewall-cmd --reload > /dev/null 2>&1
        echo -e "\033[32m
        Nginx 安装成功！
        \033[0m"
        echo -e "\033[32m
        - Nginx 版本：${version}
        - Nginx 安装路径：${install_path}/${file_name}/bin
        - Nginx 配置文件路径：${install_path}/${file_name}/bin/conf/nginx.conf
        - Nginx 日志文件路径：${install_path}/${file_name}/bin/conf/nginx.conf
        - Nginx 常用命令：
          状态：service nginx status
          启动：service nginx start
          停止：service nginx stop
          重启：service nginx restart
          测试配置：service nginx test
        \033[0m"
        exit 0
    fi
}

function install_mysql() {
    if test -r /etc/init.d/mysql; then
        service mysql status
        if [[ ! $? == 1 ]]; then
            service mysql stop
	        rm -rf /var/lock/subsys/mysql
	    fi
	fi
    install_path=$1
    download_url=$2
    file_name=$3
    base_file_name=$(basename ${download_url})
    if [[ ${download_url} =~ ^http.* ]]; then
        sudo curl -o ${base_file_name} ${download_url}
    fi
    rm -rf ${install_path}/${file_name} && mkdir -p ${install_path}
    tar -zxvf ${base_file_name} -C ${install_path}
    mkdir -p ${install_path}/${file_name}/data
    mkdir -p ${install_path}/${file_name}/log
    rm -rf /etc/init.d/mysql
    \cp -rf ${install_path}/${file_name}/support-files/mysql.server /etc/init.d/mysql
    chkconfig --add mysql && chkconfig mysql on
    rm -rf /usr/bin/mysql
    rm -rf /usr/bin/mysqldump
    rm -rf /usr/bin/myisamchk
    rm -rf /usr/bin/mysqld_safe
    ln -fs ${install_path}/${file_name}/bin/mysql /usr/bin/mysql
    ln -fs ${install_path}/${file_name}/bin/mysqldump /usr/bin/mysqldump
    ln -fs ${install_path}/${file_name}/bin/myisamchk /usr/bin/myisamchk
    ln -fs ${install_path}/${file_name}/bin/mysqld_safe /usr/bin/mysqld_safe

    sudo touch ${install_path}/${file_name}/mysql.sock
    sudo touch ${install_path}/${file_name}/mysql.pid
    sudo touch ${install_path}/${file_name}/log/mysql-error.log

    rm -rf /etc/my.cnf && sudo touch /etc/my.cnf
    cat > /etc/my.cnf << EOF
[client]
socket=${install_path}/${file_name}/mysql.sock
[mysqld]
basedir=${install_path}/${file_name}
datadir=${install_path}/${file_name}/data
socket=${install_path}/${file_name}/mysql.sock
pid-file=${install_path}/${file_name}/mysql.pid
port=3306
symbolic-links=0
[mysqld_safe]
log-error=${install_path}/${file_name}/log/mysql-error.log
pid-file=${install_path}/${file_name}/mysql.pid
!includedir /etc/my.cnf.d
EOF

    sed -i "/# Made for MySQL/d" /etc/profile
    sed -i "/MYSQL_HOME/d" /etc/profile
    sudo echo "# Made for MySQL env by godcheese [godcheese@outlook.com] on $(date +%F)" >> /etc/profile
    sudo echo "export MYSQL_HOME=\"${install_path}/${file_name}\"" >> /etc/profile
    sudo echo "export PATH=\"\${MYSQL_HOME}/bin:\${PATH}\"" >> /etc/profile
    source /etc/profile
    profile=$(tail -4 /etc/profile)
    echo -e "\033[32m
    写入 /etc/profile 的环境变量内容：
    ${profile}
    \033[0m"
    groupadd -f mysql && useradd -r -g mysql mysql -s /bin/false
    chown -R mysql ${install_path}/${file_name}
    ${install_path}/${file_name}/bin/mysqld --initialize-insecure --user=mysql
    service mysql restart
    ${install_path}/${file_name}/bin/mysqladmin -u root password "123456"
    version=$(mysql --version 2>&1)
    if [[ ! $? == 0 ]]; then
	    echo -e "\033[31m
        MySQL 安装失败！
        \033[0m"
	    exit 0
    else
        firewall-cmd --zone=public --add-port=3306/tcp --permanent > /dev/null 2>&1
        firewall-cmd --reload > /dev/null 2>&1
        echo -e "\033[32m
        MySQL 安装成功！
        \033[0m"
        echo -e "\033[32m
        - MySQL 版本：${version}
        - MySQL 安装路径：${install_path}/${file_name}
        - MySQL数据保存路径：${install_path}/${file_name}/data
        - MySQL日志文件路径：${install_path}/${file_name}/log
        - MySQL 端口：3306
        - root 密码：123456
        - MySQL 常用命令：
          状态：service mysql status
          启动：service mysql start
          停止：service mysql stop
          重启：service mysql restart
        \033[0m"
        exit 0
    fi
}

show_banner

case "$1" in
    "jdk")
        echo "Installing JDK..."
        install_jdk $2 $3 $4
        ;;
    "python3")
        echo "Installing Python 3.x..."
        install_python3 $2 $3 $4
        ;;
    "maven")
        install_maven $2 $3 $4
        ;;
    "nginx")
        echo "Installing Nginx..."
        install_nginx $2 $3 $4
        ;;
    "mysql")
        echo "Installing MySQL..."
        install_mysql $2 $3 $4
        ;;
    "redis")
        echo "Installing Redis..."
        install_redis $2 $3 $4
        ;;
    "oracle")
        echo "Installing Oracle..."
        install_oracle $2 $3 $4
        ;;
    *)
        echo "请先选择安装项"
        exit 0
        ;;
esac