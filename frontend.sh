#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$PWD

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"

if [ $USERID -ne 0 ]; then
    echo -e "$R please run script with root user $N" | tee -a $LOGS_FILE
    exit 1
fi

mkdir -p $LOGS_FOLDER

VALIDATE()
{
if [ $1 -ne 0 ]; then
      echo "$2 ...FailureS"| tee -a $LOGS_FILE
      exit 1
else
     echo "$2 ... Success"| tee -a $LOGS_FILE
fi
}

dnf module disable nginx -y &>>$LOGS_FILE
dnf module enable nginx:1.24 -y &>>$LOGS_FILE
dnf install nginx -y &>>$LOGS_FILE
VALIDATE $? "Installing Nginx"

systemctl enable nginx &>>$LOGS_FILE
systemctl start nginx &>>$LOGS_FILE
VALIDATE $? "Eanable and start Nginx"

rm -rf /usr/share/nginx/html/* 
VALIDATE $? "Remove Default code"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
cd /usr/share/nginx/html 
unzip /tmp/frontend.zip
VALIDATE $? "Download and Unzip code"

rm -rf /etc/nginx/nginx.conf

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "COPYING NGINX CONF"

systemctl restart nginx 
VALIDATE $? "restart NGINX"