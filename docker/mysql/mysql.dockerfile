FROM mysql:5.7
RUN apt update &&  apt upgrade -y && apt install vim iputils-ping -y

ADD mysql/leaf_portal.sql /docker-entrypoint-initdb.d
ADD mysql/leaf_users.sql /docker-entrypoint-initdb.d
COPY mysql/my.cnf /etc/mysql/my.cnf
ADD mysql/setup_database.sh /docker-entrypoint-initdb.d/setup_database.sh


