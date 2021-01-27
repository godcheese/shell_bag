## CentOS 7、Ubuntu、Debian

> 完善程度

- [x] 基本完善

- [ ] 未完善

### Linux Usage Example：
```
Usage:
-h show usage.
-i test.tar.gz/https.example.com/test.tar.gz
-e subDirectory
-o /test
-r yes/y
```
```
-h help
-i input file
-e extract name
-o output directory
-r replace install
```

### JDK

> install_jdk.sh

- [x] CentOS/Ubuntu
    - Online install: ```curl -o install.sh https://raw.githubusercontent.com/godcheese/shell_bag/master/linux/install_jdk.sh && bash install.sh install -i https://repo.huaweicloud.com/java/jdk/8u202-b08/jdk-8u202-linux-x64.tar.gz -e jdk1.8.0_202 -o /webwork/software/jdk/jdk-8u202-linux-x64 -r yes```
    - Offline install: ```curl -o install.sh https://raw.githubusercontent.com/godcheese/shell_bag/master/linux/install_jdk.sh && bash install.sh install -i /webwork/software/jdk/jdk-8u202-linux-x64.tar.gz -e jdk1.8.0_202 -o /webwork/software/jdk/jdk-8u202-linux-x64 -r yes```

### Maven

> install_maven.sh

-  [x] CentOS/Ubuntu
    - Online install: ```curl -o install.sh https://raw.githubusercontent.com/godcheese/shell_bag/master/linux/install_maven.sh && bash install.sh install -i https://downloads.apache.org/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz -e apache-maven-3.6.3 -o /webwork/software/maven/apache-maven-3.6.3 -r yes```
    - Offline install: ```curl -o install.sh https://raw.githubusercontent.com/godcheese/shell_bag/master/linux/install_maven.sh && bash install.sh install -i /webwork/software/maven/apache-maven-3.6.3-bin.tar.gz -e apache-maven-3.6.3 -o /webwork/software/maven/apache-maven-3.6.3 -r yes```

### MySQL

> install_mysql.sh

- [x] CentOS
    - Online
      install: ```curl -o install.sh https://raw.githubusercontent.com/godcheese/shell_bag/master/linux/install_mysql.sh && bash install.sh install -i https://mirrors.tuna.tsinghua.edu.cn/mysql/downloads/MySQL-5.7/mysql-5.7.32-el7-x86_64.tar.gz -e mysql-5.7.32-el7-x86_64 -o /webwork/software/mysql/mysql-5.7.32-el7-x86_64 -r yes```
    - Offline install: ```curl -o install.sh https://raw.githubusercontent.com/godcheese/shell_bag/master/linux/install_mysql.sh && bash install.sh install -i /webwork/software/mysql/mysql-5.7.32-el7-x86_64.tar.gz -e mysql-5.7.32-el7-x86_64 -o /webwork/software/mysql/mysql-5.7.32-el7-x86_64 -r yes```
- [x] Ubuntu
    - Online install: ```curl -o install.sh https://raw.githubusercontent.com/godcheese/shell_bag/master/linux/install_mysql.sh && bash install.sh install -i https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.31-linux-glibc2.12-x86_64.tar.gz -e mysql-5.7.31-linux-glibc2.12-x86_64 -o /webwork/software/mysql/mysql-5.7.31-linux-glibc2.12-x86_64 -r yes```
    - Offline install: ```curl -o install.sh https://raw.githubusercontent.com/godcheese/shell_bag/master/linux/install_mysql.sh && bash install.sh install -i /webwork/software/mysql/mysql-5.7.31-linux-glibc2.12-x86_64.tar.gz -e mysql-5.7.31-linux-glibc2.12-x86_64 -o /webwork/software/mysql/mysql-5.7.31-linux-glibc2.12-x86_64 -r yes```

### Nginx

> install_nginx.sh

- [x] CentOS/Ubuntu
    - Online install: ```curl -o install.sh https://raw.githubusercontent.com/godcheese/shell_bag/master/linux/install_nginx.sh && bash install.sh install -i http://nginx.org/download/nginx-1.18.0.tar.gz -e nginx-1.18.0 -o /webwork/software/nginx/nginx-1.18.0 -r yes```
    - Offline install: ```curl -o install.sh https://raw.githubusercontent.com/godcheese/shell_bag/master/linux/install_nginx.sh && bash install.sh install -i /webwork/software/nginx/nginx-1.18.0.tar.gz -e nginx-1.18.0 -o /webwork/software/nginx/nginx-1.18.0 -r yes```

### Oracle 11G R2

> install_oracle11gr2.sh

- [x] CentOS
    - Offline install: ```curl -o install.sh https://raw.githubusercontent.com/godcheese/shell_bag/master/linux/install_oracle11gr2.sh && bash install.sh install -i linux.x64_11gR2_database_1of2.zip,linux.x64_11gR2_database_2of2.zip -e database -o /webwork/software/oracle/oracle11gr2 -r yes```

### Python 3.x

> install_python3.sh

- [x] CentOS/Ubuntu
    - Online install: ```curl -o install.sh https://raw.githubusercontent.com/godcheese/shell_bag/master/linux/install_python3.sh && bash install.sh install -i https://www.python.org/ftp/python/3.9.1/Python-3.9.1.tgz -e Python-3.9.1 -o /webwork/software/python/Python-3.9.1 -r yes```
    - Offline install: ```curl -o install.sh https://raw.githubusercontent.com/godcheese/shell_bag/master/linux/install_python3.sh && bash install.sh install -i /webwork/software/python/Python-3.9.1.tgz -e Python-3.9.1 -o /webwork/software/python/Python-3.9.1 -r yes```

### Redis

> install_redis.sh

- [x] CentOS/Ubuntu
    - Online install: ```curl -o install.sh https://raw.githubusercontent.com/godcheese/shell_bag/master/linux/install_redis.sh && bash install.sh install -i http://download.redis.io/releases/redis-6.0.9.tar.gz -e redis-6.0.9 -o /webwork/software/redis/edis-6.0.9 -r yes```
    - Offline install: ```curl -o install.sh https://raw.githubusercontent.com/godcheese/shell_bag/master/linux/install_redis.sh && bash install.sh install -i /webwork/software/redis/redis-6.0.9.tar.gz -e redis-6.0.9 -o /webwork/software/redis/edis-6.0.9 -r yes```