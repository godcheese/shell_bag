#!/usr/bin/env bash
# encoding: utf-8

# http://github.com/godcheese/shell_bag
# author: godcheese [godcheese@outlook.com]
# description: Install Maven

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

# install_maven
function install_maven() {
  echo_info "\nInstalling Maven..."
  install_path="$1"
  download_url="$2"
  file_name="$3"
  base_file_name=$(basename "${download_url}")
  if "${download_url}" =~ ^http.*; then
    curl -o "${base_file_name}" "${download_url}"
  fi
  rm -rf "${install_path}/${file_name}" && mkdir -p "${install_path}"
  tar -zxvf "${base_file_name}" -C "${install_path}"
  rm -rf /usr/local/bin/mvn
  ln -fs "${install_path}/${file_name}/bin/mvn" /usr/local/bin/mvn
  sed -i "/^# Made for Maven/d" /etc/profile
  sed -i "/MAVEN_HOME/d" /etc/profile
  echo "# Made for Maven env by godcheese [godcheese@outlook.com] on $(date +%F)" >>/etc/profile
  echo "export MAVEN_HOME=\"${install_path}/${file_name}\"" >>/etc/profile
  echo "export PATH=\"\${MAVEN_HOME}/bin:\${PATH}\"" >>/etc/profile
  source /etc/profile
  profile=$(tail -3 /etc/profile)
  echo_warn "\n写入 /etc/profile 的环境变量内容：\n${profile}"
  version=$(mvn --version 2>&1)
  if [ "$?" != 0 ]; then
    show_banner
    echo_error "\nMaven 安装失败！"
    exit 0
  else
    show_banner
    echo_info "\nMaven 安装成功！\n- Maven 版本：${version}\n- Maven 安装路径：${install_path}/${file_name}"
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
  install_maven "$2" "$3" "$4"
  ;;
"uninstall")
  uninstall_maven "$2" "$3" "$4"
  ;;
*)
  echo_error "\n请输入正确的命令"
  exit 0
  ;;
esac
