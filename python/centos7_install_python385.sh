#!/usr/bin/env bash

# yum -y install zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel libffi-devel  gcc

curl -o https://www.python.org/ftp/python/3.8.5/Python-3.8.5.tar.xz
tar -zxvf Python-3.8.5.tar.xz
mkdir /usr/local/python3
cd Python-3.8.5
./configure --prefix=/usr/local/python3  --with-ssl
make all && make install
make clean && make distclean
ln -s /usr/local/python3/bin/python3 /usr/bin/python3
ln -s /usr/local/python3/bin/pip3 /usr/bin/pip3