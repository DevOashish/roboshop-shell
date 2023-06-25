script=$(realpath "$0")
script_path=$(dirname "$script")
source ${script_path}/common.sh


print_head "Copy mongodbrepo file"
cp mongodb.repo /etc/yum.repos.d/mongodb.repo &>>$log_file
func_status_check $?


print_head "Install mongodb"
yum install mongodb-org -y &>>$log_file
func_status_check $?


print_head "Update mongodb address"
sudo sed -i -e 's|127.0.0.1|0.0.0.0|' /etc/mongod.conf
func_status_check $?


print_head "enable and restart mongodb"
systemctl enable mongod &>>$log_file
systemctl restart mongod &>>$log_file
func_status_check $?
