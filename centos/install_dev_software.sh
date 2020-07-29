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
    sed -i '/JAVA_HOME/d' /etc/profile
    sed -i '/# Made for JDK/d' /etc/profile
    sed -i '/^JAVA_HOME/d' /etc/profile
    sed -i '/^export JAVA_HOME/d' /etc/profile
    sed -i '/^export CLASSPATH/d' /etc/profile
    sed -i '/^export CLASSPATH/d' /etc/profile
    sed -i '/^export PATH$/d' /etc/profile
    sudo echo " " >> /etc/profile
    sudo echo "# Made for JDK env by godcheese [godcheese@outlook.com] on $(date +%F)" >> /etc/profile
    sudo echo "export JAVA_HOME=${install_path}/${file_name}" >> /etc/profile
    sudo echo "export CLASSPATH=.:\$JAVA_HOME/jre/lib/rt.jar:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar" >> /etc/profile
    sudo echo "PATH=\$JAVA_HOME/bin:\$PATH" >> /etc/profile
    sudo echo "export PATH" >> /etc/profile
    profile=$(tail -4 /etc/profile)
    echo -e "\033[32m
    写入 /etc/profile 的环境变量内容：
    ${profile}
    \033[0m"
    source /etc/profile
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

function install_python() {
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
    sed -i '/JAVA_HOME/d' /etc/profile
    sed -i '/# Made for JDK/d' /etc/profile
    sed -i '/^JAVA_HOME/d' /etc/profile
    sed -i '/^export JAVA_HOME/d' /etc/profile
    sed -i '/^export CLASSPATH/d' /etc/profile
    sed -i '/^export CLASSPATH/d' /etc/profile
    sed -i '/^export PATH$/d' /etc/profile
    sudo echo " " >> /etc/profile
    sudo echo "# Made for JDK env by godcheese [godcheese@outlook.com] on $(date +%F)" >> /etc/profile
    sudo echo "export JAVA_HOME=${install_path}/${file_name}" >> /etc/profile
    sudo echo "export CLASSPATH=.:\$JAVA_HOME/jre/lib/rt.jar:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar" >> /etc/profile
    sudo echo "PATH=\$JAVA_HOME/bin:\$PATH" >> /etc/profile
    sudo echo "export PATH" >> /etc/profile
    profile=$(tail -4 /etc/profile)
    echo -e "\033[32m
    写入 /etc/profile 的环境变量内容：
    ${profile}
    \033[0m"
    source /etc/profile
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



show_banner
if [[ $1x == "jdk"x ]]; then
    echo "Installing jdk..."
    install_jdk $2 $3 $4
elif [[ $1x == "python"x ]]; then
    echo "Installing python..."
    install_python $2 $3 $4
elif [[ $1x == "maven"x ]]; then
    echo "Installing maven..."
    install_maven $2 $3 $4
elif [[ $1x == "nginx"x ]]; then
    echo "Installing nginx..."
    install_nginx $2 $3 $4
elif [[ $1x == "mysql"x ]]; then
    echo "Installing mysql..."
    install_mysql $2 $3 $4
elif [[ $1x == "oracle"x ]]; then
    echo "Installing oracle..."
    install_oracle $2 $3 $4
else
    echo "请选择安装项"
fi

