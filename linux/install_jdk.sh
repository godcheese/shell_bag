#!/usr/bin/env bash
# encoding: utf-8

# http://github.com/godcheese/shell_bag
# author: godcheese [godcheese@outlook.com]
# description: Install JDK

echo_error() { echo -e "\033[031;1m$*\033[0m"; }
echo_warn() { echo -e "\033[033;1m$*\033[0m"; }
echo_info() { echo -e "\033[032;1m$*\033[0m"; }

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
  "ubuntu")
    release_name="Ubuntu"
    release_full_version="${release_version}"
    release_version=$(echo "${release_version}" | awk -F '.' '{print $1}')
    ;;
  *)
    echo_error "\nUnsupported system.\n"
    exit 0
    ;;
  esac
}
check_system

# install_jdk
function install_jdk() {
  echo_info "\nInstalling JDK..."
  input="$1"
  extract="$2"
  output="$3"
  replace="$4"
  which=$(which java 2>&1)
  echo "${which}" | grep "/usr/bin/which: no" "${which}" &>/dev/null
  if [ "$?" == 1 ]; then
    if [ ! -z "${which}" ]; then
      echo_warn "You have installed: ${which}"
      if [ -z "${replace}" ]; then
        read -p "Do you want to overwrite the installation ?(no)": replace
      fi
      if [ -z "${replace}" ]; then
        replace="no"
      fi
      replace=$(echo "${replace}" | tr [A-Z] [a-z])
      if [[ "${replace}" =~ ^y|yes$ ]]; then
        echo_warn "Overwrite installation..."
        rm -rf "${which}"
      else
        echo_warn "Do not overwrite installation and exit."
        exit 0
      fi
    fi
  fi
  base_filename=$(basename "${input}")
  rm -rf "${output}" && mkdir -p "${output}"
  if [[ "${input}" =~ ^http.* ]]; then
    curl -o "${base_filename}" "${input}"
    tar -zxvf "${base_filename}"
  else
    tar -zxvf "${input}"
  fi
  if [ "$(pwd)/${extract}" != "${output}" ]; then
    mv "${extract}/"* "${output}"
    rm -rf "${extract}"
  fi
  rm -rf /usr/local/bin/java
  rm -rf /usr/local/bin/javac
  rm -rf /usr/local/bin/jar
  ln -fs "${output}/bin/java" /usr/local/bin/java
  ln -fs "${output}/bin/javac" /usr/local/bin/javac
  ln -fs "${output}/bin/jar" /usr/local/bin/jar
  sed -i "/^# Made for JDK/d" /etc/profile
  sed -i "/JAVA_HOME/d" /etc/profile
  sed -i "/CLASSPATH/d" /etc/profile
  echo "# Made for JDK env by godcheese [godcheese@outlook.com] on $(date +%F)" >>/etc/profile
  echo "export JAVA_HOME=\"${output}\"" >>/etc/profile
  echo "export CLASSPATH=\".:\${JAVA_HOME}jre/lib/rt.jar:\${JAVA_HOME}/lib/dt.jar:\${JAVA_HOME}/lib/tools.jar\"" >>/etc/profile
  echo "export PATH=\"\${JAVA_HOME}/bin:\${PATH}\"" >>/etc/profile
  source /etc/profile
  profile=$(tail -4 /etc/profile)
  echo_warn "\n写入 /etc/profile 的环境变量内容：\n${profile}"
  version=$(java -version 2>&1)
  if [ "$?" != 0 ]; then
    show_banner
    echo_error "\nJDK 安装失败！\n"
    exit 1
  else
    show_banner
    echo_info "\nJDK 安装成功！\n- JDK 版本： ${version}\n- JDK 安装路径：${output}\n"
    exit 0
  fi
}

case "$1" in
"install")
  shift 1
  usage="Usage:
-h show usage.
-i test.tar.gz/https.example.com/test.tar.gz
-e subDirectory
-o /test
-r yes/y"
  while getopts "hi:e:o:r:" arg; do
    case $arg in
    i)
      input="$OPTARG"
      ;;
    e)
      extract="$OPTARG"
      ;;
    o)
      output="$OPTARG"
      ;;
    r)
      replace="$OPTARG"
      ;;
    h)
      echo "${usage}"
      exit 0
      ;;
    ?)
      echo "${usage}"
      exit 1
      ;;
    esac
  done
  shift $((OPTIND - 1))
  if [ -z "${input}" ] || [ -z "${extract}" ] || [ -z "${output}" ]; then
    echo_error "\nInvalid argument."
    echo "${usage}"
    exit 1
  fi
  install_jdk "${input}" "${extract}" "${output}" "${replace}"
  ;;
"uninstall")
  shift 1
  echo "Not yet developed."
  ;;
*)
  echo_error "\n请输入正确的命令：\n install/uninstall"
  exit 1
  ;;
esac
