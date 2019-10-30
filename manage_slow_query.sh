#!/bin/bash
## Author: Michael Ramsey
## Objective Enable Slow query logging for MySQL/MariaDB and allow user to see the logs.
## How to use. username state(on or off)
# ./manage_slow_query.sh username on
# bash manage_slow_query.sh username on
# Enable slow qyery log and symlink for user cooluser 
# bash manage_slow_query.sh cooluser on

Today=$(date +"%Y-%m-%d")

USER=$1
SLOWQUERYState=${2^^}

if [ -z "$1" ]
then
  echo "sorry you didn't give me a username"
  exit 2
fi

if [ -z "$2" ]
then
  echo "sorry you didn't give me a value(ON/OFF) to set slow_query_log too"
  exit 2
fi


echo "Show current status"
mysql -u root -e "SHOW GLOBAL VARIABLES LIKE '%slow_query_log%';"

#Backup current config
cp /etc/my.cnf /etc/my.cnf-bak_"$Today"


#Setup Slow query logging
if [ "$SLOWQUERYState" == "ON" ] ; then
        echo "Setting up Slow query logging"
	if [[ -f /var/log/mysql-slow.log ]]
	then
		echo "Slow Query log file already exists"
		#Ensure perms and ownership are correct
		chown mysql:root /var/log/mysql-slow.log
		chmod 640 /var/log/mysql-slow.log
		echo "enable slow_query_log"
		mysql -u root -e "set global slow_query_log = 'ON';"
		
		echo "Specify slow_query_log path"
		mysql -u root -e "set global slow_query_log_file ='/var/log/mysql-slow.log';"
		
		echo "Symlink slow query log to users home directory: /home/$USER/mysql-slow.log"
		ln -s /var/log/mysql-slow.log /home/"$USER"/mysql-slow.log
	    
		echo "Add $USER to mysql group: usermod -a -G mysql $USER"
                usermod -a -G mysql "$USER"
		
		echo "chown file so its owned by $USER:mysql"
		chown "$USER":mysql /home/"$USER"/mysql-slow.log 


	else
		echo "Creating Slow Query log" 
		touch /var/log/mysql-slow.log
		chown mysql:root /var/log/mysql-slow.log
		chmod 640 /var/log/mysql-slow.log
		
		echo "enable slow_query_log"
		mysql -u root -e "set global slow_query_log = 'ON';"
		
		echo "Specify slow_query_log path"
		mysql -u root -e "set global slow_query_log_file ='/var/log/mysql-slow.log';"
		
		echo "Symlink slow query log to users home directory: /home/$USER/mysql-slow.log"
		ln -s /var/log/mysql-slow.log /home/"$USER"/mysql-slow.log
	    
		echo "Add $USER to mysql group: usermod -a -G mysql $USER"
                usermod -a -G mysql "$USER"
		
		echo "chown file so its owned by $USER:mysql"
		chown "$USER":mysql /home/"$USER"/mysql-slow.log 
	fi

#Disable Slow query logging
elif [ "$SLOWQUERYState" == "OFF" ] ; then
	echo "Disable slow_query_log"
	mysql -u root -e "set global slow_query_log = 'OFF';"
	
	echo "Remove Symlink for slow query to users home directory: unlink /home/$USER/mysql-slow.log"
	unlink /home/"$USER"/mysql-slow.log
	
	echo "copy slow query log to $USER home directory /home/$USER/mysql-slow.log"
	cp /var/log/mysql-slow.log /home/"$USER"/mysql-slow.log_"$Today"
	
	echo "chown $USER:$USER /home/$USER/mysql-slow.log_$Today"
	chown "$USER":"$USER" /home/"$USER"/mysql-slow.log_"$Today"
	    
	echo "remove USER from mysql group by setting back to own group: usermod -G ${USER} ${USER}"
        usermod -G "$USER" "$USER"

else 
	echo "No Slow Query Request Provided"
	
        fi
echo "Show end status"
        mysql -u root -e "SHOW GLOBAL VARIABLES LIKE 'slow_query_log';"