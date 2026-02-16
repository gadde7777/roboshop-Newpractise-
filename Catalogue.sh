#!/bin/bash
R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
N="\e[0m"
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

dnf module disable nodejs -y
VALIDATE $? "Disable Nodejs"

dnf module enable nodejs:20 -y
VALIDATE $? "Disable Nodejs 20"

dnf install nodejs -y &>>$LOGS_FILE
VALIDATE $? "Install Nodejs"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
VALIDATE $? "Adding System User"

mkdir /app 
VALIDATE $? "Creating App Directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
VALIDATE $? "Downloading Code"

# cd /app 
# unzip /tmp/catalogue.zip