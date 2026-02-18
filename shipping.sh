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

dnf install maven -y
VALIDATE $? "Install Maven"

id roboshop &>>$LOGS_FILE

if [ $? -ne 0 ] ; then

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
VALIDATE $? "Adding System User"

else 
echo -e "Roboshop User already exists.....$Y SKIPPING $N"
fi

mkdir -p /app 
VALIDATE $? "Creating App Directory"

curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOGS_FILE
VALIDATE $? "Downloading Code"

cd /app 
VALIDATE $? "Moving App Directory"

rm -rf /app/*
VALIDATE $? "Deleting Old Code"

unzip /tmp/shipping.zip &>>$LOGS_FILE
VALIDATE $? "Unzip Catalogue Code"


cd /app 
VALIDATE $? "Moving App Directory"

mvn clean package &>>$LOGS_FILE
VALIDATE $? "Installing and Building Shipping"

mv target/shipping-1.0.jar shipping.jar 
VALIDATE $? "Renaming Shipping Jar"

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service
VALIDATE $? "Created Systemctl service"

systemctl daemon-reload &>>$LOGS_FILE
VALIDATE $? "Daemon Reload"

systemctl enable shipping &>>$LOGS_FILE
VALIDATE $? "Enabling Shipping"

systemctl start shipping &>>$LOGS_FILE
VALIDATE $? "Start Shipping"

dnf install mysql -y &>>$LOGS_FILE
VALIDATE $? "Installing Mysql"

mysql -h mysqldb.daws88straining.online -uroot -pRoboShop@1 -e 'use cities'

if [ $? -ne 0 ]; then

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql &>>$LOGS_FILE
mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql &>>$LOGS_FILE
mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$LOGS_FILE

VALIDATE $? "Loading data in to mySQLDB"

else
echo -e " Data already loaded ---$G Skipping $N"
fi

systemctl restart shipping &>>$LOGS_FILE
VALIDATE $? "Restarting Mysql"