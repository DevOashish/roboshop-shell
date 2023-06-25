script=$(realpath "$0")
script_path=$(dirname "$script")
source ${script_path}/common.sh
mysql_root_password=$1

if [ -z "$mysql_root_password" ]; then
  echo Input MySQL Root Password Missing
  exit
fi

echo -e "\e[36m>>>>>>>>> disable mysql lastest version <<<<<<<<\e[0m"
dnf module disable mysql -y &>>$log_file
func_status_check $?


echo -e "\e[36m>>>>>>>>> Copy to mysql repo <<<<<<<<\e[0m"
cp ${script_path}/mysql.repo /etc/yum.repos.d/mysql.repo &>>$log_file
func_status_check $?

echo -e "\e[36m>>>>>>>>> Install mysql-community <<<<<<<<\e[0m"
yum install mysql-community-server -y &>>$log_file
func_status_check $?

echo -e "\e[36m>>>>>>>>> Start and enable mysql <<<<<<<<\e[0m"
systemctl enable mysqld
systemctl start mysqld &>>$log_file
func_status_check $?

echo -e "\e[36m>>>>>>>>> Reset the password of mysql <<<<<<<<\e[0m"
mysql_secure_installation --set-root-pass $mysql_root_password &>>$log_file
func_status_check $?
