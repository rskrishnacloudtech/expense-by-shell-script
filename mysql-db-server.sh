#!/bin/bash

# Getting the user id of the logged in user.
USERID=$(id -u)

# Creating a LOFGILE_NAME with TIMESTAMP and SCRIPT_NAME to store the logs of a commands.
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE_NAME=/tmp/$SCRIPT_NAME-$TIMESTAMP.log

# Declaring a color codes to used in the logs.
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

# MySql root password.
mysql_root_password=ExpenseApp@1

# Function to check that exit status of the command ran with colors to the result.
VALIDATE() {
    if [ $1 -ne 0 ]
    then
        echo -e "$2.... is $R FAILED $N"
    else
        echo -e "$2.... is $G SUCCESS $N"
    fi
}

# Checking that userid is 0 or not with colors to the result.
if [ $USERID -ne 0 ]
then
    echo -e "$R Please run this script with root access $N"
    exit 1
else
    echo -e "$G You are a root user $N"
fi

# Installing mysql-server in the EC2 instance.
dnf install mysql-server -y &>> LOGFILE_NAME
VALIDATE $? "Installing mysql-server"

# Enabling the mysqld service.
systemctl enable mysqld &>> LOGFILE_NAME
VALIDATE $? "Enabling mysqls service"

# Startign the mysqld service.
systemctl start mysqld &>> LOGFILE_NAME
VALIDATE $? "Starting the mysqld service"

# Resetting the mysql default root password by applying the idempotency.
mysql -h db.expense.rskcloudtech.online -uroot -p${mysql_root_password}
if [ $? -ne 0 ]
then
    echo -e "$G Root passowrd is not set already. Setting now.... $N"
    mysql_secure_installation --set-root-pass ${mysql_root_password}  &>> LOGFILE_NAME
    VALIDATE $? "Resetting mysql root password"
else
    echo -e "Root password is already set... $Y SKIPPING $N"
fi