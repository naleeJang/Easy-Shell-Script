#!/bin/bash

# Pacemaker 모니터링 대상서버 정보 저장
hosts="cluster01 cluster02"

for host in $hosts; do
  echo "#### HOST:: $host ####"
  # pacemaker 상태 체크
  chk_cluster=$(ssh -q mon@$host sudo pcs status | grep 'failed' | wc -l)
  
  # pacemaker 상태 체크 결과가 없으면 문제가 없는것으로 인식
  if [[ $chk_cluster -eq 0 ]]
  then
     echo "Pacemaker status is normal."
  # pacemaker 상태 체크 결과가 있으면 문제가 있으므로 pacemaker 상태를 보여줌.
  else
     echo "Please check pacemaker status."
     echo "***********************************"
     echo "$(ssh -q mon@$host sudo pcs status)"
  fi
done
