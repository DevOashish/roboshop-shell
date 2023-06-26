script=$(realpath "$0")
script_path=$(dirname "$script")
source ${script_path}/common.sh
mysql_root_password=$1

if [ -z "$mysql_root_password" ]; then
  echo Input MySQL Root Password Missing
  exit 1
fi

print_head "disable mysql lastest version"
dnf module disable mysql -y &>>$log_file
func_status_check $?


print_head "Copy to mysql repo"
cp ${script_path}/mysql.repo /etc/yum.repos.d/mysql.repo &>>$log_file
func_status_check $?

print_head "Install mysql-community"
yum install mysql-community-server -y &>>$log_file
func_status_check $?

print_head "Start and enable mysql"
systemctl enable mysqld
systemctl start mysqld &>>$log_file
func_status_check $?

print_head "Reset the password of mysql"
mysql_secure_installation --set-root-pass $mysql_root_password &>>$log_file
func_status_check $?
