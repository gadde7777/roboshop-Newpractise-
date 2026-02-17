#!/bin/bash
R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
N="\e[0m"

# SCRIPT_DIR=$PWD
# MONGODB_HOST=mongodb.daws88straining.online

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


dnf module disable redis -y &>>$LOGS_FILE
VALIDATE $? "Disable redis"

dnf module enable redis:7 -y &>>$LOGS_FILE
VALIDATE $? "Enable redis"

dnf install redis -y 
VALIDATE $? "Install redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf

VALIDATE $? "Allowing Remote Connections"

systemctl enable redis 
VALIDATE $? "Enable redis"

systemctl start redis 
VALIDATE $? "Start redis"