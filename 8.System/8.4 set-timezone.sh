#!/bin/bash

# Timezone을 설정할 대상정보 및 명령어 저장
servers="host01 host02 host03"
cmd1="timedatectl status | grep 'Time zone'"
cmd2="timedatectl set-timezone $1"

# timezone 또는 패스워드 둘 중 하나라도 입력하지 않았다면 스크립트 종료
if [[ -z $1 ]] || [[ -z $1 ]]; then
  echo -e 'Please input timezone and password\nUsage: sh set-timezone.sh Seoul/Asia password'
  exit; 
fi

for server in $servers
do
  # 해당 서버의 설정된 timezone 정보 조회
  timezone=$(sshpass -p $2 ssh root@$server "$cmd1" | awk '{print $3}')
  echo "$server: $timezone"

  # 설정하고자 하는 timezone과 조회된 timezone이 다른지 확인
  if [[ $timezone != $1 ]]
  then
    # timezone이 서로 다르면 해당 서버에 입력받은 timezone으로 설정 
    sshpass -p $2 ssh root@$server $cmd2
    echo "$server timezone changed to $1"
  fi
done

