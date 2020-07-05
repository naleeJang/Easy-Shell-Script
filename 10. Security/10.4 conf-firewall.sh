#!/bin/bash

# 운영체제 타입 확인
ostype=$(cat /etc/*release| grep ID_LIKE | sed "s/ID_LIKE=//;s/\"//g")

read -p "Please input ports(ex: http 123/tcp 123/udp) : " ports

if [[ -z $ports ]]; then echo "You didn't input port. Please retry."; exit; fi

# 운영체제가 페도라 계열일 경우
if [[ $ostype == "fedora" ]]; then
  # firewalld 실행상태 체크
  run_chk=$( firewall-cmd --state )
  if [[ $run_chk == "running" ]]; then
    # 입력받은 port 만큼 반복
    for port in $ports; do
       # service port 인지 일반 port인지 체크
       chk_port=$(echo $port | grep '^[a-zA-Z]' | wc -l)
       # service port일 경우
       if [[ chk_port -eq 1 ]]; then
         firewall-cmd --add-service=$port
         firewall-cmd --add-service=$port --permanent
       # 일반 port 일 경우
       else
         firewall-cmd --add-port=$port
         firewall-cmd --add-port=$port --permanent
       fi
    done
    # port 추가 결과 확인
    firewall-cmd --list-all
  fi
# 운영체제가 데비안 계열일 경우
elif [[ $ostype == "debian" ]]; then
  # ufw 실행상태 체크
  run_chk=$( ufw status | grep ": active" | wc -l )
  if [[ $run_chk -eq 1 ]]; then
    # 입력받은 port만큼 반복
    for port in $ports; do
      ufw allow $port
    done
    # port 추가 결과 확인
    ufw status numbered
  fi
fi
