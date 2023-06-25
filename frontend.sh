script=$(realpath "$0")
script_path=$(dirname "$script")
source ${script_path}/common.sh

    
print_head "Install Nginx"
yum install nginx -y &>>$log_file
func_status_check $?


 print_head "Copy roboshop conf file"
 cp roboshop.conf /etc/nginx/default.d/roboshop.conf &>>$log_file
 func_status_check $?


print_head "remove old files "
rm -rf /usr/share/nginx/html/* &>>$log_file
func_status_check $?


print_head "Download Application information"
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip &>>$log_file
func_status_check $?


print_head "Extract and unzip the content"
cd /usr/share/nginx/html &>>$log_file
unzip /tmp/frontend.zip &>>$log_file
func_status_check $?


print_head "reStart and enable nginx server"
systemctl enable nginx &>>$log_file
systemctl restart nginx &>>$log_file
func_status_check $?
