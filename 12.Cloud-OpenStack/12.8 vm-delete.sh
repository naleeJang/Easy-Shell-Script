#!/bin/bash

# 인증파일 export
source ~/adminrc

echo "This script will make a script about instance delete."

# 오픈스택 명령어를 이용한 인스턴스 시작 명령 생성
openstack server list --all-projects -c ID -f value | awk '{print "openstack server delete "$1}' > ~/vm_delete.sh
