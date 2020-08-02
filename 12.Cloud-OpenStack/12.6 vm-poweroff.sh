#!/bin/bash

# 인증파일 export
source ~/adminrc

if [[ -n "$1" ]]; then

  # 호스트명 조회
  Shost=$(openstack compute service list -c Binary -c Host -f value | grep compute | grep " $1" | awk '{print $2}')

  echo "This script will make a script about $Shost instance power off."

  # 오픈스택 명령어를 이용한 인스턴스 전원종료 명령 생성
  openstack server list --host $Shost --all-projects -c ID -f value | awk '{print "openstack server stop "$1}' > ~/vm_poweroff_$1.sh  
else
  echo "Please input hostname." 
  echo "ex) sh vm-poweroff.sh com01" 
fi
