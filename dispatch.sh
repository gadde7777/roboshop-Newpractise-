#!/bin/bash
R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
N="\e[0m"

SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.daws88straining.online

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

dnf install golang -y&>>$LOGS_FILE
VALIDATE $? "Install Dispatch"

id roboshop &>>$LOGS_FILE

if [ $? -ne 0 ] ; then

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
VALIDATE $? "Adding System User"

else 
echo -e "Roboshop User already exists.....$Y SKIPPING $N"
fi

mkdir -p /app 
VALIDATE $? "Creating App Directory"

curl -o /tmp/dispatch.zip https://roboshop-artifacts.s3.amazonaws.com/dispatch-v3.zip &>>$LOGS_FILE
VALIDATE $? "Downloading Code"

cd /app 
VALIDATE $? "Moving to App Directory"

rm -rf /app/*
VALIDATE $? "Deleting Old Code"

unzip /tmp/dispatch.zip &>>$LOGS_FILE
VALIDATE $? "Unzip dispatch Code"

cd /app 
VALIDATE $? "Moving to App Directory"

go mod init dispatch
go get 
go build
VALIDATE $? "Getting Dependencies"

cp $SCRIPT_DIR/dispatch.service /etc/systemd/system/dispatch.service
VALIDATE $? "Created Systemctl service"

systemctl daemon-reload
systemctl enable dispatch &>>$LOGS_FILE
systemctl start dispatch &>>$LOGS_FILE
VALIDATE $? "Enabling Start Dispatch"