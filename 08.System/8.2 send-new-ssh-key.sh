#!/bin/bash

# 접속할 서버 정보, SSH 키 경로, 공개키 경로를 변수에 저장
servers="host01 host02"
sshKey="$HOME/.ssh/key.pem"
sshPub="$HOME/.ssh/key.pem.pub"

# SSH Key 생성
ssh-keygen -q -N "" -f $sshKey

# 생성된 SSH Key를 해당 서버에 복사
for server in $servers
do
  echo $server
  sshpass -p "$1" ssh-copy-id -i $sshPub stack@$server
done

