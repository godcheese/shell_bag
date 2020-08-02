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
    mkdir -p ${install_path}
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
    version=$(java -version 2>&1 | sed '1!d' | sed -e 's/"//g' -e 's/version//')
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

function install_python3() {
    yum install -y gcc
    yum install -y zlib*
    install_path=$1
    download_url=$2
    file_name=$3
    base_file_name=$(basename ${download_url})
    if [[ ${download_url} =~ ^http.* ]]; then
        sudo curl -o ${base_file_name} ${download_url}
    fi
    mkdir -p ${install_path}
    tar -zxvf ${base_file_name} -C ${install_path}
    ${install_path}/${file_name}/configure --prefix=${install_path}/${file_name}  --with-ssl
    make && make install
    rm -rf /usr/bin/python
    rm -rf /usr/bin/pip
    ln -fs ${install_path}/${file_name}/bin/python3 /usr/bin/python3
    ln -fs ${install_path}/${file_name}/bin/pip3 /usr/bin/pip3
    sed -i "/# Made for Python/d" /etc/profile
    sed -i "/PYTHON_HOME/d" /etc/profile
    sudo echo " " >> /etc/profile
    sudo echo "# Made for Python env by godcheese [godcheese@outlook.com] on $(date +%F)" >> /etc/profile
    sudo echo "export PYTHON_HOME=\"${install_path}/${file_name}\"" >> /etc/profile
    sudo echo "export PATH=\"\${PYTHON_HOME}/bin:\${PATH}\"" >> /etc/profile
    source /etc/profile
    profile=$(tail -4 /etc/profile)
    echo -e "\033[32m
    写入 /etc/profile 的环境变量内容：
    ${profile}
    \033[0m"
    version1=$(python3 --version)
    version2=$(pip3 --version)
    if [[ ! $? == 0 ]]; then
	    echo -e "\033[31m
        Python 安装失败！
        \033[0m"
	    exit
    else
        echo -e "\033[32m
        Python 安装成功！
        \033[0m"
        echo -e "\033[32m
        - Python 版本：${version1}
        - Pip 版本：${version2}
        - Python 安装路径：${install_path}/${file_name}
        \033[0m"
        exit
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
    mkdir -p ${install_path}
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
    version=$(maven --version)
    if [[ ! $? == 0 ]]; then
	    echo -e "\033[31m
        Maven 安装失败！
        \033[0m"
	    exit
    else
        echo -e "\033[32m
        Maven 安装成功！
        \033[0m"
        echo -e "\033[32m
        - Maven 版本：${version}
        - Maven 安装路径：${install_path}/${file_name}
        \033[0m"
        exit
    fi
}

function install_nginx() {
#     yum install -y gcc
#     yum install -y zlib*
    install_path=$1
    download_url=$2
    file_name=$3
    base_file_name=$(basename ${download_url})
    if [[ ${download_url} =~ ^http.* ]]; then
        sudo curl -o ${base_file_name} ${download_url}
    fi
    mkdir -p ${install_path}
    tar -zxvf ${base_file_name} -C ${install_path}
    ${install_path}/${file_name}/configure --prefix=${install_path}/${file_name}  --sbin-path=nginx --conf-path=${install_path}/${file_name}/conf/nginx.conf --pid-path=${install_path}/${file_name}/logs/nginx.pid
    make && make install
    rm -rf /usr/bin/nginx
    ln -fs ${install_path}/${file_name}/nginx /usr/bin/nginx
    sed -i "/# Made for Nginx/d" /etc/profile
    sed -i "/NGINX_HOME/d" /etc/profile
    sudo echo " " >> /etc/profile
    sudo echo "# Made for Python env by godcheese [godcheese@outlook.com] on $(date +%F)" >> /etc/profile
    sudo echo "export NGINX_HOME=\"${install_path}/${file_name}\"" >> /etc/profile
    sudo echo "export PATH=\"\${NGINX_HOME}:\${PATH}\"" >> /etc/profile
    source /etc/profile
    profile=$(tail -4 /etc/profile)
    echo -e "\033[32m
    写入 /etc/profile 的环境变量内容：
    ${profile}
    \033[0m"
    version=$(nginx --version)
    if [[ ! $? == 0 ]]; then
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
        - Nginx 安装路径：${install_path}/${file_name}
        \033[0m"
        exit
    fi
}

function install_mysql() {
    install_path=$1
    download_url=$2
    file_name=$3
    base_file_name=$(basename ${download_url})
    if [[ ${download_url} =~ ^http.* ]]; then
        sudo curl -o ${base_file_name} ${download_url}
    fi
    mkdir -p ${install_path}
    tar -zxvf ${base_file_name} -C ${install_path}
    mkdir -p ${install_path}/${file_name}/data
    mkdir -p ${install_path}/${file_name}/log
    cp -f ${install_path}/${file_name}/support-files/mysql.server /etc/init.d/mysql
    chkconfig --add mysql
    chkconfig mysql on
    rm -rf /usr/bin/mysql
    rm -rf /usr/bin/mysqldump
    rm -rf /usr/bin/myisamchk
    rm -rf /usr/bin/mysqld_safe
    ln -fs ${install_path}/${file_name}/bin/mysql /usr/bin/mysql
    ln -fs ${install_path}/${file_name}/bin/mysqldump /usr/bin/mysqldump
    ln -fs ${install_path}/${file_name}/bin/myisamchk /usr/bin/myisamchk
    ln -fs ${install_path}/${file_name}/bin/mysqld_safe /usr/bin/mysqld_safe

    rm -rf ${install_path}/${file_name}/${file_name}.lock && sudo touch ${install_path}/${file_name}/${file_name}.sock
    rm -rf ${install_path}/${file_name}/${file_name}.pid && sudo touch ${install_path}/${file_name}/${file_name}.pid
    rm -rf ${install_path}/${file_name}/log/${file_name}-error.log && sudo touch ${install_path}/${file_name}/${file_name}-error.log
    rm -rf /etc/my.cnf && sudo touch /etc/my.cnf
    cat > /etc/my.cnf << EOF
[client]
socket=${install_path}/${file_name}/${file_name}.sock
[mysqld]
basedir=${install_path}/${file_name}
datadir=${install_path}/${file_name}/${file_name}/data
socket=${install_path}/${file_name}/${file_name}.sock
pid-file=${install_path}/${file_name}/${file_name}.pid
port=3306
symbolic-links=0
[mysqld_safe]
log-error=${install_path}/${file_name}/log/${file_name}-error.log
pid-file=${install_path}/${file_name}/${file_name}.pid
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
    groupadd mysql && useradd -r -g mysql mysql
    chown -R mysql ${mysql_path}
    ${install_path}/${file_name}/bin/mysqld --initialize-insecure --user=mysql
    service mysql restart
    ${install_path}/${file_name}/bin/mysqladmin -u root password "123456"
    version=$(mysql -version)
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
        - MySQL 安装路径：${install_path}/${file_name}
        - MySQL data 路径：${install_path}/${file_name}/data
        - MySQL log 路径：${install_path}/${file_name}/log
        - MySQL 端口：3306
        - root 密码：123456
        \033[0m"
        exit
    fi
}

show_banner

if [[ $1x == "jdk"x ]]; then
    echo "Installing JDK..."
    install_jdk $2 $3 $4
elif [[ $1x == "python3"x ]]; then
    echo "Installing Python 3.x..."
    install_python3 $2 $3 $4
elif [[ $1x == "maven"x ]]; then
    echo "Installing Maven..."
    install_maven $2 $3 $4
elif [[ $1x == "nginx"x ]]; then
    echo "Installing Nginx..."
    install_nginx $2 $3 $4
elif [[ $1x == "mysql"x ]]; then
    echo "Installing MySQL..."
    install_mysql $2 $3 $4
elif [[ $1x == "oracle"x ]]; then
    echo "Installing Oracle..."
    install_oracle $2 $3 $4
else
    echo "请先选择安装项"
fi

