#!/bin/bash

# Flavor 하나만 생성할 경우
if [[ $1 == "" ]]; then
  # Flavor 정보를 입력받음.
  read -p "Flavor Name : " flavor_name
  read -p "Number of VCPUs : " vcpus
  read -p "Memory size in MB : " rams
  read -p "Disk size in GB : " disks
  read -p "Ephemeral disk size in GB: " edisks

  # 인증 정보 export
  source ~/adminrc

  # Cli를 이용한 flavor 생성
  openstack flavor create \
  --vcpus $vcpus \
  --ram $rams \
  --disk $disks \
  --ephemeral $edisks \
  --public \
  $flavor_name

# Flavor를 여러개 만들 경우
else
  # 파라메터로 받은 파일 경로가 존재하는지 확인
  if [[ -f $1 ]]; then
    while read line
    do

       # 인증 정보 export
      source ~/adminrc

      # Cli를 이용하여 flavor 생성
      echo "Creating Flavor $(echo $line | awk '{print $1}')"
      openstack flavor create \
      --vcpus $(echo $line | awk '{print $2}') \
      --ram $(echo $line | awk '{print $3}') \
      --disk $(echo $line | awk '{print $4}') \
      --ephemeral $(echo $line | awk '{print $5}') \
      --public \
      $(echo $line | awk '{print $1}')
    done < $1
  else
    echo "This is no file. Please try to run this script again."
    exit;
  fi
fi
 
