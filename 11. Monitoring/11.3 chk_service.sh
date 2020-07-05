#!/bin/bash

# 서비스 모니터링 대상서버 정보 저장
hosts="host01 host02 host03"
services="httpd haproxy rabbitmq"
ports="80 443 8080 5672 15672"

for host in $hosts; do
  echo "#### HOST:: $host ####"
  # 호스트별 서비스 상태 체크
  for service in $services; do
    chk_service=$(ssh mon@$host sudo systemctl is-active $service)
    # 서비스 상태 체크 결과 출력
    if [[ $chk_service == "active" ]]; then
      echo "$service state is active."
    else
      echo "$service state is inactive. Please check $service"
    fi
  done

  # 호스트별 서비스 포트 상태 체크
  for port in $ports; do
    chk_port=$(ssh mon@$host sudo netstat -ntpl | grep $port | wc -l)
    if [[ $chk_port > 0 ]]; then
       echo "This port $port is open."
    else
       echo "This port $port is not found. Please check your system."
    fi
  done
done

