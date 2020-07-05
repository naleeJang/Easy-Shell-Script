#!/bin/bash

# 모니터링 대상서버 정보 저장
hosts="host01 host02 host03"

for host in $hosts;do
  echo "#### HOST:: $host ####"
  # 해당 호스트에 Docker가 설치되어 있는지 확인
  chk_docker=$(ssh -q mon@$host rpm -qa | grep -c docker)
  if [[ $chk_docker > 0]]; then
    echo "This system's container engine is docker."
    # docker 서비스가 실행중인지 확인
    chk_service=$(ssh -q mon@$host systemctl is-active docker)
    if [[ $chk_service == "active" ]]; then
      echo "docker running state is active."
    else
      echo "Please check your docker state."
    fi
    # container 프로세스 확인
    chk_container=$(ssh -q mon@$host docker ps | grep -c seconds)
    if [[ $chk_container > 0 ]]; then
      echo "Please check your container state."
      echo "$(ssh -q mon@$host docker ps | grep seconds)"
    else
      echo "Container status is normal."
    fi
  fi

 # 해당 호스트에 Docker가 설치되어 있는지 확인
  chk_podman=$(ssh -q mon@$host rpm -qa | grep -c podman)
  if [[ $chk_podman > 0]]; then
    echo "This system's container engine is podman."
    # container 프로세스 확인
    chk_container=$(ssh -q mon@$host podman ps | grep -c seconds)
    if [[ $chk_container > 0 ]]; then
      echo "Please check your container state."
      echo "$(ssh -q mon@$host podman ps | grep seconds)"
    else
      echo "Container status is normal."
    fi
  fi
done
