#!/bin/bash

# 설정 변경 대상 노드들
nodes="host01 host02 host03"
# 환경설정 확인 명령어
cmd1="cat /etc/lvm/lvm.conf | grep -e '^[[:space:]]*global_filter =' | wc -l"
# 환경설정 파일 백업 명령어
cmd2="cp /etc/lvm/lvm.conf /etc/lvm/lvm.conf.bak"
# 환경설정 변경 명령어
cmd3="sed -i 's/\(# global_filter =.*\)/\1\n	global_filter = [ ""r|.*|"" ]/g' /etc/lvm/lvm.conf"
# lvm관련 서비스 재시작 명령어
cmd4="systemctl restart lvm2*"

stty -echo
read -p "Please input Hosts password: " pw 
stty echo

if [[ -z $pw ]]; then echo -e "\nYou need a password for this script. Please retry script"; exit; fi

for node in $nodes
do
  echo -e "\n$node"
  conf_chk=$(sshpass -p $pw ssh root@$node $cmd1)
  if [[ conf_chk -eq 0 ]]; then
    # 설정 변경 전 백업.
    echo "lvm.conf backup"
    sshpass -p $pw ssh root@$node $cmd2
    # sed를 이용해 설정을 변경함.
    echo "lvm.conf reconfiguration"
    sshpass -p $pw ssh root@$node $cmd3
    # lvm 관련 서비스 재시작
    echo "lvm related service restart"
    sshpass -p $pw ssh root@$node $cmd4
  fi
done
