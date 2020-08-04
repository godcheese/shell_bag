#!/bin/sh
# chkconfig: - 85 15
# description: nginx is a World Wide Web server. It is used to serve.
# author: godcheese [godcheese@outlook.com]

bin_path=
if test -z "${bin_path}" ; then
    bin_path="/usr/bin/nginx"
fi
echo ${bin_path}

if ! test -r "${bin_path}" ; then
    echo "Nginx not found:${bin_path}"
    exit 0
fi

case "$1" in
    "start")
        echo "Starting nginx"
        "${bin_path}"
        echo "Nginx start successful"
        ;;
    "stop")
        echo "Stopping nginx"
        "${bin_path}" -s stop
        echo "Nginx stop successful"
        ;;
    "reload")
        echo "Reloading nginx"
        ${bin_path} -s reload
        echo "Nginx reload successful"
        ;;
esac