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

dnf install mysql-server -y &>>$LOG_FILE_NAME
Validate $? "Installing MySQL Server"

systemctl enable mysqld &>>$LOG_FILE_NAME
Validate $? "Installing MySQL Server"

systemctl start mysqld &>>$LOG_FILE_NAME
Validate $? "Installing MySQL Server"

    mysql -h mysql.daws82s.xyz -u root -pExpenseApp@1 -e 'show databases;' &>>$LOG_FILE_NAME
    if [ $? -ne 0 ]
     then 
            echo "MYSQL Root password not setup" &>>$LOG_FILE_NAME
            mysql_secure_installation --set-root-pass ExpenseApp@1
            Validate $? "Setting Root Password"
    else
            echo -e "MYSQL root password already setup ...$Y skipping $N" 
    fi 
