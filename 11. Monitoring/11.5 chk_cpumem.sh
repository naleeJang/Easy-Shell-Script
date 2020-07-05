#!/bin/bash

# 모니터링 대상서버 정보 저장
hosts="host01 host02 host03"

for host in $hosts; do
  echo "#### HOST:: $host ####"
  # cpu, memory 사용률 체크
  chk_cpu=$(ssh -q mon@$host mpstat | grep all | awk '{print $4}')
  chk_mem=$(ssh -q mon@$host free -h | grep Mem | awk '{print $4}')
  
  # cpu, memory 사용률 체크 결과
  echo "CPU usage is ${chk_cpu}%"
  echo "Memory free size is ${chk_mem}"
done
