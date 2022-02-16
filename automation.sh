#!/bin/bash

#------------------Running update package ---------
sudo apt update -y

	echo "Package manager updated"

#------------------Installing  Apache2 ---------
sudo apt install apache2 -y

	echo "apache2 installed"

#-------------Doing unmasking-----------------------

sudo systemctl unmask apache2

#------------------Checking Apache2 service status ---------
if [`service apache2 status | grep running | wc -l` == 1 ]; 

then
	echo "apache2 is running"
else
	service apache2 start
	echo "apache2 has started"	

fi

#------------------Checking Apache2 service enabled ---------
if [`service apache2 status | grep enabled | wc -l` == 1 ]; 

then
	echo "apache2 is already enabled"
else
	 sudo systemctl enable apache2
        echo "Apache2 enabled"

fi

#------------------Converting log files into tar ---------

cd /var/log/apache2/

timestamp=$(date '+%d%m%Y-%H%M%S')
tar -cvf  /tmp/alan-httpd-logs-${timestamp}.tar *.log

#------------------Copying to s3 ---------

s3bucket="upgrad-alanbenson/logs"

# Installing awscli 
sudo apt update
sudo apt install awscli

aws s3 \
cp /tmp/alan-httpd-logs-${timestamp}.tar \
s3://${s3bucket}/alan-httpd-logs-${timestamp}.tar

#------------------Checking Inventory file --------


if [ -e /var/www/html/inventory.html ]
then
        echo "Inventory exists"
else
        touch /var/www/html/inventory.html
        echo "<b>Log Type &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Date Created &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Type &nbsp;&nbsp;$
        
fi

echo "<br>httpd-logs &nbsp;&nbsp;&nbsp;&nbsp; ${timestamp} &nbsp;&nbsp;&nbsp;&nbsp; tar &nbsp;&nbsp;&nbsp;&nbsp;" `du -h $

#------------------Checking Cron Job --------

if [ -e /etc/cron.d/automation ]
then
        echo "Cron job exists"

else
	touch /etc/cron.d/automation
	echo "0 4 * * * root /root/Automation_Project/automation.sh" > /etc/cron.d/automation
        echo "Cron job added"
fi


