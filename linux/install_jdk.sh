#!/usr/bin/env bash
# encoding: utf-8.0

# http://github.com/godcheese/shell_bag
# author: godcheese [godcheese@outlook.com]
# description: Install JDK

error_echo(){ echo -e "\033[031;1m$(date +"%F %T")\tERROR\t$@\033[0m"; exit 1;}
warn_echo() { echo -e "\033[033;1m$(date +"%F %T")\tWARN\t$@\033[0m"; }
info_echo() { echo -e "\033[032;1m$(date +"%F %T")\tINFO\t$@\033[0m"; }

# install jdk
function install_jdk() {
  info_echo "\nInstalling JDK..."
  install_path=$1
  download_url=$2
  file_name=$3
  base_file_name=$(basename ${download_url})
  if [[ ${download_url} =~ ^http.* ]]; then
    curl -o ${base_file_name} ${download_url}
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
  echo "# Made for JDK env by godcheese [godcheese@outlook.com] on $(date +%F)" >>/etc/profile
  echo "export JAVA_HOME=\"${install_path}/${file_name}\"" >>/etc/profile
  echo "export CLASSPATH=\".:\${JAVA_HOME}jre/lib/rt.jar:\${JAVA_HOME}/lib/dt.jar:\${JAVA_HOME}/lib/tools.jar\"" >>/etc/profile
  echo "export PATH=\"\${JAVA_HOME}/bin:\${PATH}\"" >>/etc/profile
  source /etc/profile
  profile=$(tail -4 /etc/profile)
  warn_echo "
  写入 /etc/profile 的环境变量内容：
  ${profile}"
  version=$(java -version 2>&1)
  if [[ ! $? == 0 ]]; then
    error_echo "
    JDK 安装失败！"
    exit 0
  else
    info_echo "
    JDK 安装成功！
    - JDK 版本：${version}
    - JDK 安装路径：${install_path}/${file_name}"
    exit 0
  fi
}

# show banner
function show_banner() {
  info_echo "
  -------------------------------------------------
  | Install for Linux                             |
  | http://github.com/godcheese/shell_bag         |
  | author: godcheese [godcheese@outlook.com]     |
  -------------------------------------------------"
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
  warn_echo "\n请输入正确的命令"
  exit 0
  ;;
esac
