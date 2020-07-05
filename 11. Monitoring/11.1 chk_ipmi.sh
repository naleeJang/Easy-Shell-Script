#!/bin/bash

# IPMI IP 및 User ID를 변수에 저장
ipmi_hosts="192.168.122.10 192.168.122.11 192.168.122.12 192.168.122.13"
ipmi_userid="admin"

# IPMI User ID에 해당하는 패스워드를 입력받음.
read -p "Please input ipmi password : " ipmi_pw
# 패스워드 입력을 안했으면 입력을 하지 않았다는 메시지를 보여주고, 스크립트 종료
if [[ -z $ipmi_pw ]]; then echo "You didn't input ipmi password. Please retry."; exit; fi

# ipmitool 명령어를 이용하여 해당 서버의 전원 체크
for host in $ipmi_hosts
do
  echo "#### IPMI HOST:: $host ####"
  power_stat=$(ipmitool -I lanplus -H $host -L ADMINISTRATOR -U $ipmi_userid -P $impi_pw -v power status)
  echo "$power_stat"
done
