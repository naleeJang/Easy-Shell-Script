#!/bin/bash

#-----------------------------
# 모니터링 대상 서버정보를 변수에 저장
#-----------------------------
Cluster_servers="clus01 clus02 clus03"
Container_servers="con01 con02 con03"
General_servers="gen01 gen02 gen03 gen04 gen05"

LOG_FILE=""
#-----------------------------
# 모니터링 로그 파일 생성
#-----------------------------
function make_logs()
{
  DATE=$(date +%Y%m%d%H%M)
  LOG_FILE="/var/log/daily_system_chk/chk_system_$DATE.log"
  sudo touch $LOG_FILE
  sudo chmod 777 $LOG_FILE
}

#-----------------------------
# 모니터링 로그 파일 권한 변경
#-----------------------------
function change_logs()
{
  sudo chmod 644 $LOG_FILE
}

#-----------------------------------
# 모니터링 결과를 화면에 출력하고 로그에 저장
#-----------------------------------
function print_msg()
{
  Message=$1
  Date=$(date "+%Y-%m-%d %H:%M")
  echo "$Date [Daily_System_chk] $Message" >> $LOG_FILE
  echo "$Date $Message" 
}

make_logs
print_msg "#-----------------------------"
print_msg "# Check System Power"
print_msg "#-----------------------------"

for i in {1..3}
do
  print_msg "#### NODE:: clus0$i ####"
  power_stat=$(ipmitool -I lanplus -H 192.168.0.1$i -L ADMINISTRATOR -U admin -P P@ssw0rd! -v power status)
  print_msg "$power_stat"
done

for i in {1..3}
do
  print_msg "#### NODE:: con0$i ####"
  power_stat=$(ipmitool -I lanplus -H 192.168.0.2$i -L ADMINISTRATOR -U admin -P P@ssw0rd! -v power status)
  print_msg "$power_stat"
done

for i in {1..5}
do
  print_msg "#### NODE:: gen0$i ####"
  power_stat=$(ipmitool -I lanplus -H 192.168.0.3$i -L ADMINISTRATOR -U admin -P P@ssw0rd! -v power status)
  print_msg "$power_stat"
done

print_msg "#-----------------------------"
print_msg "# Cluster Servers"
print_msg "#-----------------------------"

for i in $Cluster_servers
do
  print_msg "#### NODE:: $i ####"

  if [ $i = "clus01" ]
  then
    print_msg "#-----------------------------"
    print_msg "# Check Clustering"
    print_msg "#-----------------------------"
    cluster_stat=$(ssh -q mon@$i sudo pcs status | grep 'failed' | wc -l)

    if [ $cluster_stat -eq 0 ]
    then
      print_msg "Pacemaker status is normal"
    else
      print_msg "Please check pacemaker"
      print_msg "$(ssh -q mon@$i sudo pcs status)"
    fi
  fi

  print_msg "#-----------------------------"
  print_msg "# Check Network"
  print_msg "#-----------------------------"
  grep_nic="-e eno1 -e eno3 -e enp24s0f0 -e enp24s0f1"
  down_link=$(ssh mon@$host "ip link show | grep $grep_nic | grep 'state DOWN' | awk -F ': ' '{print \$2}'")
  down_link_cnt=$(ssh mon@$host "ip link show | grep $grep_nic | grep 'state DOWN' | wc -l")
  if [[ $down_link_cnt -eq 0 ]]; then
    print_msg "Network States are normal."
  else
    print_msg "Network $down_link is down. Please check network status." 
  fi

  print_msg "#-----------------------------"
  print_msg "# Check CPU"
  print_msg "#-----------------------------"
  mem_stat=$(ssh -q mon@$i sudo mpstat | grep all | awk '{print $4}')
  print_msg "CPU usage is ${chk_cpu}%. If CPU usage is high, please check system cpu status."  

  print_msg "#-----------------------------"
  print_msg "# Check Memory"
  print_msg "#-----------------------------"
  mem_stat=$(ssh -q mon@$i sudo free -h | grep -i mem | awk '{print $4}')
  print_msg "Memory free size is $mem_stat. If memory free size is low, please check system memory status."  

  print_msg "#-----------------------------"
  print_msg "# Check Service Log"
  print_msg "#-----------------------------"
  for service in "httpd mariadb"; do
    chk_log=$(ssh mon@$host sudo tail /var/log/$service/*.log | grep -i error | wc -l)
    
    if [[ $chk_log -eq 0 ]]; then
      echo "No error services logs. The $service is normal"
    else
      echo "Please check service $service logs and service $service"  <------ 02
      echo "$(ssh mon@$host sudo tail /var/log/$service/*.log | grep -i error)"
    fi
  done
done

print_msg "#-----------------------------"
print_msg "# Container Servers"
print_msg "#-----------------------------"

for i in $Container_servers
do
  print_msg "#### NODE:: $i ####"

  print_msg "#-----------------------------"
  print_msg "# Check Network"
  print_msg "#-----------------------------"
  grep_nic="-e eno1 -e eno3 -e enp24s0f0 -e enp24s0f1"
  down_link=$(ssh mon@$host "ip link show | grep $grep_nic | grep 'state DOWN' | awk -F ': ' '{print \$2}'")
  down_link_cnt=$(ssh mon@$host "ip link show | grep $grep_nic | grep 'state DOWN' | wc -l")
  if [[ $down_link_cnt -eq 0 ]]; then
    print_msg "Network States are normal."
  else
    print_msg "Network $down_link is down. Please check network status." 
  fi

  print_msg "#-----------------------------"
  print_msg "# Check CPU"
  print_msg "#-----------------------------"
  mem_stat=$(ssh -q mon@$i sudo mpstat | grep all | awk '{print $4}')
  print_msg "CPU usage is ${chk_cpu}%. If CPU usage is high, please check system cpu status"  

  print_msg "#-----------------------------"
  print_msg "# Check Memory"
  print_msg "#-----------------------------"
  mem_stat=$(ssh -q mon@$i sudo free -h | grep -i mem | awk '{print $4}')
  print_msg "Memory free size is $mem_stat. If memory free size is low, please check system memory status"  

  chk_docker=$(ssh -q mon@$host rpm -qa | grep -c docker)
  if [[ $chk_docker > 0]]; then
    print_msg "#-----------------------------"
    print_msg "# Check Container - Docker"
    print_msg "#-----------------------------"
    chk_service=$(ssh -q mon@$host systemctl is-active docker)
    if [[ $chk_service == "active" ]]; then
      print_msg "Docker running state is active."
      chk_container=$(ssh -q mon@$host docker ps | grep -c seconds)
      if [[ $chk_container > 0 ]]; then
        print_msg "Please check your container state."
        print_msg "$(ssh -q mon@$host docker ps | grep seconds)"
      else
        print_msg "Container status is normal."
      fi
    else
      print_msg "Please check your docker state."
    fi
  fi

  chk_podman=$(ssh -q mon@$host rpm -qa | grep -c podman)
  if [[ $chk_podman > 0]]; then
    print_msg "#-----------------------------"
    print_msg "# Check Container - Podman"
    print_msg "#-----------------------------"
    chk_container=$(ssh -q mon@$host podman ps | grep -c seconds)
    if [[ $chk_container > 0 ]]; then
      print_msg "Please check your container state."
      print_msg "$(ssh -q mon@$host podman ps | grep seconds)"
    else
      print_msg "Container status is normal."
    fi
  fi
done

print_msg "#-----------------------------"
print_msg "# General Servers"
print_msg "#-----------------------------"

for i in $General_servers
do
  print_msg "#### NODE:: $i ####"

  print_msg "#-----------------------------"
  print_msg "# Check Network"
  print_msg "#-----------------------------"
  grep_nic="-e eno1 -e eno3 -e enp24s0f0 -e enp24s0f1"
  down_link=$(ssh mon@$host "ip link show | grep $grep_nic | grep 'state DOWN' | awk -F ': ' '{print \$2}'")
  down_link_cnt=$(ssh mon@$host "ip link show | grep $grep_nic | grep 'state DOWN' | wc -l")
  if [[ $down_link_cnt -eq 0 ]]; then
    print_msg "Network States are normal."
  else
    print_msg "Network $down_link is down. Please check network status." 
  fi

  print_msg "#-----------------------------"
  print_msg "# Check CPU"
  print_msg "#-----------------------------"
  mem_stat=$(ssh -q mon@$i sudo mpstat | grep all | awk '{print $4}')
  print_msg "CPU usage is ${chk_cpu}%. If CPU usage is high, please check system cpu status"  

  print_msg "#-----------------------------"
  print_msg "# Check Memory"
  print_msg "#-----------------------------"
  mem_stat=$(ssh -q mon@$i sudo free -h | grep -i mem | awk '{print $4}')
  print_msg "Memory free size is $mem_stat. If memory free size is low, please check system memory status"  

done
change_logs
