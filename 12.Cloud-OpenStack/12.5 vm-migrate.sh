#!/bin/bash

# 인증파일 export
source ~/adminrc

# 원 호스트명과 대상 호스트명 파라미터 저장
HNAME=$1 
TNAME=$2 

if [[ -n "$HNAME" ]] && [[ -n "$TNAME" ]] 
then 
  # 원 호스트명 조회 및 추출
  Shost=$(openstack compute service list -c Binary -c Host -f value | grep compute | grep " $HNAME" | awk '{print $2}')
  # 대상 호스트명 조회 및 추출
  Dhost=$(openstack compute service list -c Binary -c Host -f value | grep compute | grep " $TNAME" | awk '{print $2}') 

  echo "This script will make a script about $Shost instance migrate to $Dhost" 

  # 오픈스택 명령어를 이용한 인스턴스 마이그레이션 명령 생성
  openstack server list --host $Shost --all-projects -c ID | grep -v '+-' | grep -v ID | awk -v t=$Dhost '{print "openstack server migrate "$2" --live-migration --host "t" --wait"}' > ~/vm_migrate_$HNAME.sh 
  
  echo "Make the script finish. you can see /home/stack/vm_migrate_$HNAME.sh" 

else 
  echo "Please input source and target hostnames." 
  echo "ex) sh vm_migrate.sh com01 com02" 
fi
