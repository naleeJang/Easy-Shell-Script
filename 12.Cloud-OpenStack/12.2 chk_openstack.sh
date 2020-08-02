#!/bin/bash

CON_CNT=34
COM_CNT=8

CON_HOSTS="ctrl1 ctrl2 ctrl3"
COM_HOSTS="com1 com2 com3 com4"

# 컨트롤러 노드 컨테이너 상태 및 서비스 로그 확인
for host in $CON_HOSTS
do
  echo "========== $host ============"
  echo ">>>>>> Check container's status <<<<<<"
  cnt=$(ssh heat-admin@$host "sudo docker ps | grep -v IMAGE | wc -l")
  if [[ $cnt -eq $CON_CNT ]]; then
    echo "The $host containers count is $cnt. This is normal."
  else
    echo "Please check container's status"
    ssh heat-admin@$host "sudo docker ps"
  fi

  echo ">>>>>> Check service logs <<<<<<"  
  ssh heat-admin@$host "echo 'tail /var/log/containers/*/*.log | grep -i error | wc -l' > mon-logs.sh"
  err_cnt=$(ssh heat-admin@$host "sudo sh mon-logs.sh")
  if [[ $err_cnt -eq 0 ]]; then
    echo "The $host has no error logs. This system is normal."
  else
    echo "Please check service logs"
    ssh heat-admin@$host "echo 'tail /var/log/containers/*/*.log | grep -i error' > mon-logs.sh"
    ssh heat-admin@$host "sudo sh mon-logs.sh"
  fi
done

# 컴퓨트 노드 컨테이너 상태 및 서비스 로그 확인
for host in $COM_HOSTS
do
    echo "========== $host ============"
  echo ">>>>>> Check container's status <<<<<<"
  cnt=$(ssh heat-admin@$host "sudo docker ps | grep -v IMAGE | wc -l")
  if [[ $cnt -eq $COM_CNT ]]; then
    echo "The $host containers count is $cnt. This is normal."
  else
    echo "Please check container's status"
    ssh heat-admin@$host "sudo docker ps"
  fi

  echo ">>>>>> Check service logs <<<<<<"  
  ssh heat-admin@$host "echo 'tail /var/log/containers/*/*.log | grep -i error | wc -l' > mon-logs.sh"
  err_cnt=$(ssh heat-admin@$host "sudo sh mon-logs.sh")
  if [[ $err_cnt -eq 0 ]]; then
    echo "The $host has no error logs. This system is normal."
  else
    echo "Please check service logs"
    ssh heat-admin@$host "echo 'tail /var/log/containers/*/*.log | grep -i error' > mon-logs.sh"
    ssh heat-admin@$host "sudo sh mon-logs.sh"
  fi
done

echo "#============================"
echo "# Check OpenStack Services "
echo "#============================"
# 오픈스택 명령어를 이용한 서비스 확인
source /home/stack/adminrc

# 컴퓨트 서비스 확인
echo "openstack compute service list"
openstack compute service list
# 볼륨 서비스 확인
echo "openstack volume service list"
openstack volume service list
# 네트워크 서비스 확인
echo "openstack network agent list"
openstack network agent list
