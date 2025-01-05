#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"

N="\e[0m"

LOGS_FOLDER="/var/log/expense-logs"
LOGS_FILE=$(echo $0 | cut -d "." -f1 )
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOGS_FILE-$TIMESTAMP.log"

Validate(){
     if [ $1 -ne 0 ]
        then 
            echo -e "$2...$R FAILURE $N"
            exit 1
        else 
            echo -e "$2...$G SUCCESS $N"
        fi
}

CHECK_ROOT(){
 
 if [ $USERID -ne 0 ]
  then 
     echo "ERROR:: you must have sudo access to execute this script"
    exit 1 #other than o
fi 
}

echo "script started executing at: $TIMESTAMP" &>>$LOG_FILE_NAME

CHECK_ROOT

dnf module disable nodejs -y &>>$LOG_FILE_NAME
Validate $? "Disabling existing default nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE_NAME
Validate $? "Enabling  nodejs 20"

dnf install nodejs -y &>>$LOG_FILE_NAME
Validate $? "Installing Nodejs"

useradd expense &>>$LOG_FILE_NAME
Validate $? "Adding Expense User"

mkdir /app &>>$LOG_FILE_NAME
Validate $? "Creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
Validate $? "Downloading backend"

cd /app

unzip /tmp/backend.zip &>>$LOG_FILE_NAME
Validate $? "unzip backend"

npm install &>>$LOG_FILE_NAME
Validate $? "Installing dependencies"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service

#prepare Mysql schema
dnf install mysql -y &>>$LOG_FILE_NAME
Validate $? "Installing Mysql client"

mysql -h mysql.daws82s.xyz -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE_NAME
Validate $? "setting up the transaction schema and tables"

systemctl daemon-reload &>>$LOG_FILE_NAME
Validate $? "daemon reload"

systemctl enable backend &>>$LOG_FILE_NAME
Validate $? "Enabling backend"

systemctl start backend &>>$LOG_FILE_NAME
Validate $? "starting backend"
