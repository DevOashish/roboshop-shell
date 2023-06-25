app_user=roboshop
script=$(realpath "$0")
script_path=$(dirname "$script")
log_file=/tmp/rroboshop.log
# rm -f $log_file

print_head() {
  echo -e "\e[35m>>>>>>>>> $1 <<<<<<<<\e[0m"
  echo -e "\e[35m>>>>>>>>> $1 <<<<<<<<\e[0m" &>>$log_file

}

 func_status_check() {
   if [ $1 -eq 0 ]; then

  echo -e "\e[32msuccess\e[0m"
  else
   echo -e "\e[31mfailure\e[0m"
   echo "Refer the log file /tmp/rroboshop.log for more information"
   exit 1
   fi
}

 schema_setup() {

   if [ "$schema_setup" == "mongo" ]; then
    print_head "Copy MongoDB repo"
    cp ${script_path}/mongodb.repo /etc/yum.repos.d/mongodb.repo &>>$log_file
    func_status_check $?

     print_head "Install MongoDB Client"
     yum install mongodb-org-shell -y &>>$log_file
     func_status_check $?

    print_head "Load Schema"
     mongo --host mongodb-dev.devoash.tech </app/schema/${component}.js &>>$log_file
    func_status_check $?

  fi

  if [ "$schema_setup" == "mqsql" ]; then
 
     print_head "Install MySQL Client"
     yum install mysql -y &>>$log_file
     func_status_check $?
       
    print_head "Load Schema"
    mysql -h mysql-dev.devoash.tech -uroot -p${mysql_root_password} < /app/schema/${component}.sql &>>$log_file
    func_status_check $?
    
    fi
}

func_mscommonsteps() {

  print_head "Add user"
  id ${app_user} &>>/tmp/rroboshop.log
  if [ $? -ne 0 ] ; then
    useradd ${app_user} &>>/tmp/rroboshop.log
  fi
  func_status_check $?


   print_head "remove and create app dir"
    rm -rf /app &>>$log_file
    mkdir /app &>>$log_file
    func_status_check $?

    print_head "Download app content"
    curl -L -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>>$log_file
     func_status_check $?


     print_head "unzip app content"
     cd /app &>>$log_file
     unzip /tmp/${component}.zip &>>$log_file
     func_status_check $?

}

func_systemd_service(){
  print_head "apth copy"
  cp ${script_path}/${component}.service /etc/systemd/system/${component}.service &>>$log_file
   func_status_check $?


 print_head "system start and reload ${component} services"

     systemctl daemon-reload &>>$log_file
     systemctl enable ${component} &>>$log_file
     systemctl restart ${component} &>>$log_file
      func_status_check $?


}



func_nodejs() {
  print_head "Configuring NodeJS repos"
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>$log_file
   func_status_check $?


  print_head "Install NodeJS"
  yum install nodejs -y &>>$log_file
   func_status_check $?

   func_mscommonsteps

   print_head "Install NodeJS Dependencies"
   npm install &>>$log_file
    func_status_check $?
 

   schema_setup
   
   func_systemd_service

}

func_java() {


print_head "Install Maven"
yum install maven -y &>>$log_file

 func_status_check $?

 
 func_mscommonsteps

  print_head "Install maven Dependencies"
  mvn clean package  &>>$log_file

 func_status_check $?

mv target/${component}-1.0.jar ${component}.jar  &>>$log_file

schema_setup

func_systemd_service
  
  }
  
  func_python() { 
  
  print_head "Install Python"
  yum install python36 gcc python3-devel -y &>>$log_file
  func_stat_check $?

  func_mscommonsteps

  print_head "Install Python Dependencies"
  pip3.6 install -r requirements.txt &>>$log_file
  func_stat_check $?

  print_head "Update Passwords in System Service file"
  sed -i -e "s|rabbitmq_appuser_password|${rabbitmq_appuser_password}|" ${script_path}/payment.service &>>$log_file
  func_stat_check $?

  func_systemd_service


  }