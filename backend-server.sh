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

# Disabling the nodejs application old versions.
dnf module disable nodejs -y
VALIDATE $? "Disabling the nodejs application ols versions"

# Enabling the nodejs application latest verstions.
dnf module enable nodejs:20 -y
VALIDATE $? "Enabling the nodejs application verion 20"

# INstalling nodejs application.
dnf install nodejs -y
VALIDATE $? "Installing nodejs applications"

# Creating expense user.
id expense
if [ $? -ne 0 ]
then 
    useradd expense
    VALIDATE $? "Creating the expense user"
else
    echo -e "Expense user is already created... $Y SKIPPING $N" 

# Creating a app diretory if its already created it will be skipped.
mkdir -p /app
VALIDATE $? "Creating the app directory"

# Downloading the application code.
curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
VALIDATE $? "Downloading the application code"

# Moving to app directory and deleting all the content inside app directory and unzipping the zip file.
cd /app
rm -rf /app/*
unzip /tmp/backend.zip
VALIDATE $? "Unzipping the application code"

# Installing npm package.
npm install
VALIDATE $? "Installing the npm package."

# Copying the backend.service to the /etc/systemd/system/ directory.
cp ~/expense-by-shell-script/backend.service /etc/systemd/system/backend.service
VALIDATE $? "Copied backend.service file"

# Reloading the daemon.
systemctl daemon-reload
VALIDATE $? "Daemon reload"

# Starting the backend service.
systemctl start backend
VALIDATE $? "Starting the backend service."

# Enabling the backend service.
systemctl enable backend
VALIDATE $? "Enabling the backend service"

# Installing the mysql client.
dnf install mysql -y
VALIDATE $? "Installing mysql client"

# Loading the schema.
mysql -h db.expense.rskcloudtech.online -uroot -p${mysql_root_password} < /app/schema/backend.sql
VALIDATE $? "Loading the schema."

# Restarting the backend service.
systemctl restart backend
VALIDATE $? "Restarting the backend service."