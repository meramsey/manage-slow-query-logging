This amazing tool makes a normally tedious job much easier when trying to grant a developer access to MySQL/MariaDB slow_query_logs without providing them root access.

See it in action below.

```
[root@cpanel ~]# bash manage_slow_query.sh ibqpnrso on
Show current status
+---------------------+-------------------------+
| Variable_name       | Value                   |
+---------------------+-------------------------+
| slow_query_log      | OFF                     |
| slow_query_log_file | /var/log/mysql-slow.log |
+---------------------+-------------------------+
Setting up Slow query logging
Slow Query log file already exists
enable slow_query_log
Specify slow_query_log path
Symlink slow query log to users home directory: /home/ibqpnrso/mysql-slow.log
Add ibqpnrso to mysql group: usermod -a -G mysql ibqpnrso
chown file so its owned by ibqpnrso:mysql
Show end status
+----------------+-------+
| Variable_name  | Value |
+----------------+-------+
| slow_query_log | ON    |
+----------------+-------+
[root@cpanel ~]# id ibqpnrso
uid=1008(ibqpnrso) gid=1010(ibqpnrso) groups=992(mysql),1010(ibqpnrso)
[root@cpanel ~]# ls -l /home/ibqpnrso/mysql-slow.log
lrwxrwxrwx 1 root root 23 Oct 30 10:23 /home/ibqpnrso/mysql-slow.log -> /var/log/mysql-slow.log
[root@cpanel ~]# su - ibqpnrso
Last login: Wed Oct 30 09:57:53 EDT 2019 on pts/0
[ibqpnrso@cpanel ~]$ tail -f /home/ibqpnrso/mysql-slow.log
Time                 Id Command    Argument
/usr/sbin/mysqld, Version: 10.2.27-MariaDB (MariaDB Server). started with:
Tcp port: 3306  Unix socket: /var/lib/mysql/mysql.sock
Time                 Id Command    Argument
/usr/sbin/mysqld, Version: 10.2.27-MariaDB (MariaDB Server). started with:
Tcp port: 3306  Unix socket: /var/lib/mysql/mysql.sock
Time                 Id Command    Argument
/usr/sbin/mysqld, Version: 10.2.27-MariaDB (MariaDB Server). started with:
Tcp port: 3306  Unix socket: /var/lib/mysql/mysql.sock
Time                 Id Command    Argument
^C
[ibqpnrso@cpanel ~]$ exit
logout
[root@cpanel ~]# bash manage_slow_query.sh ibqpnrso off
Show current status
+---------------------+-------------------------+
| Variable_name       | Value                   |
+---------------------+-------------------------+
| slow_query_log      | ON                      |
| slow_query_log_file | /var/log/mysql-slow.log |
+---------------------+-------------------------+
Disable slow_query_log
Remove Symlink for slow query to users home directory: unlink /home/ibqpnrso/mysql-slow.log
copy slow query log to ibqpnrso home directory /home/ibqpnrso/mysql-slow.log_2019-10-30
chown ibqpnrso:ibqpnrso /home/ibqpnrso/mysql-slow.log_2019-10-30
remove USER from mysql group by setting back to own group: usermod -G ibqpnrso ibqpnrso
Show end status
+----------------+-------+
| Variable_name  | Value |
+----------------+-------+
| slow_query_log | OFF   |
+----------------+-------+
[root@cpanel ~]# id ibqpnrso
uid=1008(ibqpnrso) gid=1010(ibqpnrso) groups=1010(ibqpnrso)
[root@cpanel ~]# ls -l /home/ibqpnrso/mysql-slow.log
ls: cannot access /home/ibqpnrso/mysql-slow.log: No such file or directory
[root@cpanel ~]# ls -l /home/ibqpnrso/mysql-slow.log_2019-10-30 
-rw-r----- 1 root root 1218 Oct 30 10:24 /home/ibqpnrso/mysql-slow.log_2019-10-30
[root@cpanel ~]#
```
