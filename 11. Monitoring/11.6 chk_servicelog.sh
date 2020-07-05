#!/bin/bash

# 모니터링 대상서버 정보 저장
hosts="host01 host02 host03"
# 모니터링 대상 서비스 정보 저장
services="httpd rabbitmq nginx"

for host in $hosts; do
  echo "#### HOST:: $host ####"

  for service in $services; do
    # service's error log 검색
    chk_log=$(ssh mon@$host sudo tail /var/log/$service/*.log | grep -i error | wc -l)
    
    # error log가 없으면 없다고 메시지를 보여줌.
    if [[ $chk_log -eq 0 ]]; then
      echo "No error services logs. The $service is normal"
    else
      # error log가 있는 경우에는 체크하라고 메시지를 보여줌.
      echo "Please check service $service logs and service $service"
      echo "$(ssh mon@$host sudo tail /var/log/$service/*.log | grep -i error)"
    fi
  done
done
