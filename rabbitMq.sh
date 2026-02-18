#!/bin/bash
R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
N="\e[0m"

SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.daws88straining.online
MYSQL_HOST=mysqldb.daws88straining.online

USERID=$(id -u)

LOGS_FOLDER="/var/log/shell-script"
LOGS_FILE="/var/log/shell-script/$0.log"


if [ $USERID -ne 0 ]; then

echo -e "$R Run with root access $N" | tee -a $LOGS_FILE
exit 1
fi

mkdir -p $LOGS_FOLDER

VALIDATE()
{
  if [ $1 -ne 0 ]; then
  echo -e "$2.......$R FAILURE $N"| tee -a $LOGS_FILE
  exit 1
  else
  echo -e "$2........$G SUCCESS $N"| tee -a $LOGS_FILE
  fi
}

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>$LOGS_FILE
VALIDATE $? "Added Rabit Mq repo"

dnf install rabbitmq-server -y &>>$LOGS_FILE
VALIDATE $? "Installing Rabbitmq server"

systemctl enable rabbitmq-server &>>$LOGS_FILE
VALIDATE $? "Enabling Rabbitmq server"

systemctl start rabbitmq-server &>>$LOGS_FILE
VALIDATE $? "Start Rabbitmq server"

rabbitmqctl add_user roboshop roboshop123 &>>$LOGS_FILE
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOGS_FILE
VALIDATE $? "Adding user and Permissions"
