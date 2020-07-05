#!/bin/bash

# 네트워크 모니터링 대상서버 정보 저장
hosts="host01 host02 host03"
nic_name="eno1 eno3 enp24s0f0 enp24s0f1"

# 모니터링 대상 NIC을 검색하기 위한 grep 옵션 생성
grep_nic=""
for nic in $nic_name; do
  grep_nic=$(echo "$grep_nic -e $nic") 
done

# For문을 돌면서 네트워크 상태 체크
for host in $hosts; do
  echo "#### HOST:: $host ####"
  down_link=$(ssh mon@$host "ip link show | grep $grep_nic | grep 'state DOWN' | awk -F ': ' '{print \$2}'")
  down_link_cnt=$(ssh mon@$host "ip link show | grep $grep_nic | grep 'state DOWN' | wc -l")

  # 네트워크 상태 체크 결과 출력
  if [[ $down_link_cnt -eq 0 ]]; then
    echo "Network States are normal."
  else
    echo "Network $down_link is down. Please check network status." 
  fi
done

