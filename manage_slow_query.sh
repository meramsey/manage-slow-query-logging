#!/bin/bash
## Author: Michael Ramsey
## https://gitlab.com/mikeramsey/manage-slow-query-logging
## Objective Enable Slow query logging for MySQL/MariaDB and allow user to see the logs.
## How to use. username state(on or off)
# ./manage_slow_query.sh username on
# bash manage_slow_query.sh username on
# Enable slow query log and symlink for user cooluser 
# bash manage_slow_query.sh cooluser on

## How to use.
# Check slow query_log:
# mysql -u root -e "SHOW GLOBAL VARIABLES LIKE '%slow_query_log%';"

# Show slow query time secs.
# mysql -u root -e "SHOW GLOBAL VARIABLES LIKE '%long_query_time%';"

# Set slow query time to to 4 secs
# mysql -u root -e "SET GLOBAL long_query_time = 4;"

# Enable slow_query_log:
# wget -O /root/manage_slow_query.sh https://gitlab.com/mikeramsey/manage-slow-query-logging/raw/master/manage_slow_query.sh; bash /root/manage_slow_query.sh USERNAME on

# Disable slow_query_log:
# bash /root/manage_slow_query.sh USERNAME off



Today=$(date +"%Y-%m-%d")

username=$1
SLOWQUERYState=${2^^}

user_homedir=$(grep -E "^${username}:" /etc/passwd | cut -d: -f6)

## Configure
####################
SLOWQUERYLOG="/var/log/mysql-slow.log"
###################

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
mysql -u root -e "SHOW GLOBAL VARIABLES LIKE '%long_query_time%';"

#Backup current config
#cp /etc/my.cnf /etc/my.cnf-bak_"$Today"


#Setup Slow query logging
if [ "$SLOWQUERYState" == "ON" ] ; then
        echo "Setting up Slow query logging"
	if [ -f $SLOWQUERYLOG ]; then
   	echo "The SLOWQUERYLOG '$SLOWQUERYLOG' exists. All good to proceed." 
	echo "";
	else
   	echo "The SLOWQUERYLOG '$SLOWQUERYLOG' was not found. Creating it now" 
	echo "";
	touch $SLOWQUERYLOG
	fi

	echo "";
	echo "Ensuring correct perms and ownership on $SLOWQUERYLOG" 
	echo "";
	chown mysql:root $SLOWQUERYLOG
	chmod 640 $SLOWQUERYLOG
	
	echo "enable slow_query_log" 
	echo "";
	mysql -u root -e "set global slow_query_log = 'ON';" 
	
	echo "Setting slow_query_log path" 
	echo "";
	mysql -u root -e "set global slow_query_log_file ='$SLOWQUERYLOG';"
		
	echo "Symlink slow query log to users home directory: ${user_homedir}/mysql-slow.log" 
	echo "";
	ln -s $SLOWQUERYLOG "$user_homedir"/mysql-slow.log
	    
	echo "Add $username to mysql group: usermod -a -G mysql $username"
	echo "";
        usermod -a -G mysql "$username"
		
	echo "chown file so its owned by $username:mysql" 
	echo "";
	chown "$username":mysql "$user_homedir"/mysql-slow.log 


#Disable Slow query logging
elif [ "$SLOWQUERYState" == "OFF" ] ; then
	echo "Disabling slow_query_log"
	echo "";
	mysql -u root -e "set global slow_query_log = 'OFF';"
	
	echo "Remove Symlink to users home directory: unlink ${user_homedir}/mysql-slow.log"
	echo "";
	unlink "$user_homedir"/mysql-slow.log
	
	echo "copy slow query log to $username home directory ${user_homedir}/mysql-slow.log_$Today"
	echo "";
	cp $SLOWQUERYLOG "$user_homedir"/mysql-slow.log_"$Today"
	
	echo "chown $username:$username ${user_homedir}/mysql-slow.log_$Today"
	echo "";
	chown "$username":"$username" "$user_homedir"/mysql-slow.log_"$Today"
	    
	echo "remove $username from mysql group. Setting back to own group: usermod -G ${username} ${username}"
	echo "";
        usermod -G "$username" "$username"

else 
	echo "No Slow Query Request Provided" 
	echo "";
	
        fi
echo "Show end status"
        mysql -u root -e "SHOW GLOBAL VARIABLES LIKE 'slow_query_log';"