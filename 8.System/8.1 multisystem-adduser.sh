#!/bin/bash

for server in "host01 host02 host03"
do
  # 여러대의 시스템에 사용자 생성 및 패스워드 설정
  echo $server
  ssh root@$server "useradd $1"
  ssh root@$server "echo $2 | passwd $1 --stdin"
done
