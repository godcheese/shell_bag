#!/usr/bin/env bash
# encoding: utf-8

# http://github.com/godcheese/shell_bag
# author: godcheese [godcheese@outlook.com]
# description: Install Python 3.x

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

# install_python3
function install_python3() {
  echo_info "\nInstalling Python 3.x..."
  input="$1"
  extract="$2"
  output="$3"
  replace="$4"
  which=$(which nginx 2>&1)
  echo "${which}" | grep "/usr/bin/which: no" "${which}" &>/dev/null
    if [ "$?" == 1 ]; then
    if [ ! -z "${which}" ]; then
      echo "You have installed: ${which}"
      if [ -z "${replace}" ]; then
        read -p "Do you want to overwrite the installation ?(no)": replace
      fi
      if [ -z "${replace}" ]; then
        replace="no"
      fi
      replace=$(echo "${replace}" | tr [A-Z] [a-z])
      if [[ "${replace}" =~ ^y|yes$ ]]; then
        echo "Overwrite installation..."
        rm -rf "${which}"
      else
        echo "Do not overwrite installation and exit."
        exit 0
      fi
    fi
  fi
  if [ "${release_id}"x == "centos"x ]; then
    yum update -y
    yum install -y gcc zlib*
  fi
  if [ "${release_id}"x == "ubuntu"x ]; then
    apt-get update -y
    apt-get install -y gcc
  fi
  current_path=$(pwd)
  base_filename=$(basename "${input}")
  rm -rf "${output}" && mkdir -p "${output}"
  if [[ "${input}" =~ ^http.* ]]; then
    curl -o "${base_filename}" "${input}"
    tar -zxvf "${base_filename}"
  else
    tar -zxvf "${input}"
  fi
  mv "${extract}/"* "${output}"
  rm -rf "${extract}"

  cd "${output}"
  ./configure --prefix="${output}" --with-ssl
  make && make install
  cd "${current_path}"
  rm -rf /usr/local/bin/pip3
  rm -rf /usr/local/bin/python3
  ln -fs "${output}/bin/python3" /usr/local/bin/python3
  ln -fs "${output}/bin/pip3" /usr/local/bin/pip3
  sed -i "/^# Made for Python/d" /etc/profile
  sed -i "/PYTHON_HOME/d" /etc/profile
  echo "# Made for Python env by godcheese [godcheese@outlook.com] on $(date +%F)" >>/etc/profile
  echo "export PYTHON_HOME=\"${output}\"" >>/etc/profile
  echo "export PATH=\"\${PYTHON_HOME}/bin:\${PATH}\"" >>/etc/profile
  source /etc/profile
  profile=$(tail -3 /etc/profile)
  echo_warn "\n写入 /etc/profile 的环境变量内容：\n${profile}"
  version1=$(python3 --version 2>&1)
  version2=$(pip3 --version 2>&1)
  if [ "$?" != 0 ]; then
    show_banner
    echo_error "\nPython 安装失败！"
    exit 1
  else
    show_banner
    echo_info "\nPython 安装成功！
- Python 版本：${version1}
- Pip 版本：${version2}
- Python 安装路径：${output}"
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
  install_python3 "${input}" "${extract}" "${output}" "${replace}"
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
