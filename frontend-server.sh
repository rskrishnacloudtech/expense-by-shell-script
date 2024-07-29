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

# Installing the nginx application.
dnf install nginx -y &>> LOGFILE_NAME
VALIDATE $? "Instaling nginx application"

# Enabling the nginx service.
systemctl enable nginx &>> LOGFILE_NAME
VALIDATE $? "Enabling the nginx service"

# Starting the nginx service.
systemctl start nginx &>> LOGFILE_NAME
VALIDATE $? "Starting the nginx service"

# Removing the content from the default html folder.
rm -rf /usr/share/nginx/html/* &>> LOGFILE_NAME
VALIDATE $? "Removing the default content from html folder"

# Downloading the application code.
curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>> LOGFILE_NAME
VALIDATE $? "Downloading the application code"

# Moving to the default html folder and unzipping the application code.
cd /usr/share/nginx/html &>> LOGFILE_NAME
unzip /tmp/frontend.zip &>> LOGFILE_NAME
VALIDATE $? "Unzippinng the application code"

# Copying the appliction expense.conf file to etc/nginx/default.d/
cp ~/expense-by-shell-script/expense.conf /etc/nginx/default.d/expense.conf &>> LOGFILE_NAME
VALIDATE $? "Copied expense.conf file"

# Restarting the nginx service.
systemctl restart nginx &>> LOGFILE_NAME
VALIDATE $? "Restartigng the nginx service"