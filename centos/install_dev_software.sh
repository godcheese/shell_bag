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
    version=$(python --version)
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
        - Python 版本：${version}
        - Python 安装路径：${install_path}/${file_name}
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

