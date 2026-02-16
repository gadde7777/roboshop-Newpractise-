#!/bin/bash
R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
N="\e[0m"

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

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying Mongo repo"

dnf install mongodb-org -y 
VALIDATE $? "Install Mongo DB Server"

systemctl enable mongod 
VALIDATE $? "Enable Mongo DB"

systemctl start mongod 
VALIDATE $? "Start Mongo DB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf

systemctl restart mongod
VALIDATE $? "reStart Mongo DB"