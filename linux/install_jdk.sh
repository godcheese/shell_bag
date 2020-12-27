#!/usr/bin/env bash
# encoding: utf-8

# http://github.com/godcheese/shell_bag
# author: godcheese [godcheese@outlook.com]
# description: Install JDK

echo_error() { echo -e "\n\033[031;1mERROR $(date +"%F %T")\t$*\033[0m"; }
echo_warn() { echo -e "\n\033[033;1mWARN $(date +"%F %T")\t$*\033[0m"; }
echo_info() { echo -e "\n\033[032;1mINFO $(date +"%F %T")\t$*\033[0m"; }

# check_system
release_id=$(awk '/^NAME="/' /etc/os-release | awk -F '"' '{print $2}' | awk -F ' ' '{print $1}' | tr 'A-Z' 'a-z' 2>&1)
release_name=
release_version=$(awk '/^VERSION="/' /etc/os-release | awk -F '"' '{print $2}' | awk -F ' ' '{print $1}' 2>&1)
release_full_version=
linux_kernel=$(uname -srm | awk -F ' ' '{print $2}' | awk -F '-' '{print $1}' 2>&1)

function check_system() {
  case "${release_id}" in
  "centos")
    release_name="CentOS"
    release_full_version=$(awk '/\W/' /etc/centos-release | awk '{print $4}' 2>&1)
    ;;
  "debian")
    release_name="Debian"
    release_full_version=$(cat /etc/debian_version 2>&1)
    ;;
  "ubuntu")
    release_name="Ubuntu"
    release_full_version="${release_version}"
    release_version=$(echo "${release_version}" | awk -F '.' '{print $1}')
    ;;
  *)
    echo_error "\nUnsupported system."
    exit 0
    ;;
  esac
}
check_system

# install_jdk
function install_jdk() {
  echo_info "\nInstalling JDK..."
  install_path="$1"
  download_url="$2"
  file_name="$3"
  base_file_name=$(basename "${download_url}")
  if [[ "${download_url}" =~ ^http.* ]]; then
    curl -o "${base_file_name}" "${download_url}"
  fi
  rm -rf "${install_path}/${file_name}" && mkdir -p "${install_path}"
  tar -zxvf "${base_file_name}" -C "${install_path}"
  rm -rf /usr/local/bin/java
  rm -rf /usr/local/bin/javac
  rm -rf /usr/local/bin/jar
  ln -fs "${install_path}/${file_name}/bin/java" /usr/local/bin/java
  ln -fs "${install_path}/${file_name}/bin/javac" /usr/local/bin/javac
  ln -fs "${install_path}/${file_name}/bin/jar" /usr/local/bin/jar
  sed -i "/^# Made for JDK/d" /etc/profile
  sed -i "/JAVA_HOME/d" /etc/profile
  sed -i "/CLASSPATH/d" /etc/profile
  echo "# Made for JDK env by godcheese [godcheese@outlook.com] on $(date +%F)" >>/etc/profile
  echo "export JAVA_HOME=\"${install_path}/${file_name}\"" >>/etc/profile
  echo "export CLASSPATH=\".:\${JAVA_HOME}jre/lib/rt.jar:\${JAVA_HOME}/lib/dt.jar:\${JAVA_HOME}/lib/tools.jar\"" >>/etc/profile
  echo "export PATH=\"\${JAVA_HOME}/bin:\${PATH}\"" >>/etc/profile
  source /etc/profile
  profile=$(tail -4 /etc/profile)
  echo_warn "\n写入 /etc/profile 的环境变量内容：\n${profile}"
  version=$(java -version 2>&1)
  if [ "$?" != 0 ]; then
    show_banner
    echo_error "\nJDK 安装失败！"
    exit 1
  else
    show_banner
    echo_info "\nJDK 安装成功！\n- JDK 版本： ${version}\n- JDK 安装路径：${install_path}/${file_name}"
    exit 0
  fi
}

# show_banner
function show_banner() {
  echo_info "
 -------------------------------------------------
 | Install for Linux                             |
 | http://github.com/godcheese/shell_bag         |
 | author: godcheese [godcheese@outlook.com]     |
 -------------------------------------------------"
}

show_banner
case "$1" in
"install")
  install_jdk "$2" "$3" "$4"
  ;;
"uninstall")
  uninstall_jdk "$2" "$3" "$4"
  ;;
*)
  echo_error "\n请输入正确的命令"
  exit 1
  ;;
esac
