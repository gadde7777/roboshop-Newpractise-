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

dnf module disable nodejs -y &>>$LOGS_FILE
VALIDATE $? "Disable Nodejs"

dnf module enable nodejs:20 -y &>>$LOGS_FILE
VALIDATE $? "Enable Nodejs 20"

dnf install nodejs -y &>>$LOGS_FILE
VALIDATE $? "Install Nodejs"

id roboshop &>>$LOGS_FILE

if [ $? -ne 0] ; then

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
VALIDATE $? "Adding System User"

else 
echo -e "Roboshop User already exists.....$Y SKIPPING $N"
fi

mkdir -p /app 
VALIDATE $? "Creating App Directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOGS_FILE
VALIDATE $? "Downloading Code"

cd /app 
VALIDATE $? "Moving to App Directory"

rm -rf /app/*
VALIDATE $? "Deleting Old Code"

unzip /tmp/catalogue.zip &>>$LOGS_FILE
VALIDATE $? "Unzip Catalogue Code"

npm install 
VALIDATE $? "Install npm dependencies"

cp $SCRIPT_DIR/Catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Created Systemctl service"

systemctl daemon-reload
VALIDATE $? "Deamon Reload service"

systemctl enable catalogue &>>$LOGS_FILE
VALIDATE $? "Enable catalogue service"

systemctl start catalogue &>>$LOGS_FILE
VALIDATE $? "Start catalogue service"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying MongoRepo"

dnf install mongodb-mongosh -y &>>$LOGS_FILE
VALIDATE $? "Install MongoDB mongosh"

 mongosh --host $MONGODB_HOST </app/db/master-data.js

# mongosh --host MONGODB-SERVER-IPADDRESS

