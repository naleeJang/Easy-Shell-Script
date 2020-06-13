#!/bin/bash

# NTP를 설치할 대상서버정보 저장
servers='host01 host02 host03'
cmd1='cat /etc/*release| grep ID_LIKE | sed "s/ID_LIKE=//;s/\"//g"'
cmd2=''

for server in $servers; do
  # 해당 서버의 운영체제 타입 확인
  ostype=$(sshpass -p $1 ssh root@$server $cmd1)

  # 운영체제가 Fedora 계열인지 Debian 계열인지 체크
  if [[ $ostype == "fedora" ]]; then
    cmd2="yum install -y ntp"
  elif [[ $ostype == "debian" ]]; then
    cmd2="apt-get install -y ntp"
  fi
  
  # 해당 운영체제에 ntp 설치
  sshpass -p $1 ssh root@$server $cmd2
done
