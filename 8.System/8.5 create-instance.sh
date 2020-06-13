#!/bin/bash

# 인스턴스명 입력
read -p "Input instance name : " vmname

# 이미지 정보
echo "== Image List =="
openstack image list -c Name | awk 'FNR==3, FNR==(NR-1) { print $2 }' | grep -v '^$'
read -p  "Input image name : " image

# 네트워크 정보
echo "== Network List =="
openstack network list -c Name | awk 'FNR==3, FNR==(NR-1) { print $2 }' | grep -v '^$'
read -p "Input network name : " net

# Flaver 정보 
echo "== Flavor List =="
openstack flavor list -c Name | awk 'FNR==3, FNR==(NR-1) { print $2 }' | grep -v '^$'
read -p "Input flavor name : " flavor

# 보안그룹 정보
echo "== Security group List =="
openstack security group list --project $OS_PROJECT_NAME -c Name | awk 'FNR==3, FNR==(NR-1) { print $2 }' | grep -v '^$'
read -p "Input security group name : " sec
secgrp=$(openstack security group list --project $OS_PROJECT_NAME -f value -c ID -c Name | grep 'default$' | awk '{print $1}')

# SSH 키 정보
echo "== Keypair List =="
openstack keypair list -c Name | awk 'FNR==3, FNR==(NR-1) { print $2 }' | grep -v '^$'
read -p "Input keypair name : " keypair

# 볼륨 생성
echo "== Create volume =="
read -p "Input volume size: " size
openstack volume create --size $size --image $image --bootable $vmname

# 인스턴스 생성
echo "Create Instance Starting"
openstack server create \
--volume $(openstack volume list --name $vmname -f value -c ID) \
--flavor $flavor \
--security-group $secgrp \
--key-name $keypair \
--network $net \
--wait \
$vmname
