#!/bin/bash

# 서울은 asiz-northeast3-a
ZONE="asia-northeast3-a"

# 인스턴스 이름 입력
read -p "Input instance name : " VM_NAME

# 이미지 정보 입력
echo "== Images List =="
gcloud compute images list | grep -e centos -e unbuntu -e rhel -e NAME
read -p "Input image family : " IMAGE
read -p "Input image proejct: " IMAGE_PROJECT

# 부팅 디스크 유형 입력
echo "== Disk Type List =="
gcloud compute disk-types list --zones $ZONE
read -p "Input disk type : " DISK_TYPE

# 부팅 디스크 사이즈 입력
read -p "Input disk size : " DISK_SIZE

# 머신 타입 입력
echo "== Machine Type List =="
gcloud compute machine-types list --zones $ZONE | grep n1-standard
read -p "Input machine type : " MACHINE_TYPE

# 네트워크 입력
echo "== Network List =="
gcloud compute networks list 
read -p "Input network name : " NETWORK

# 인스턴스 생성
echo "== Create Instance =="
gcloud compute instances create $VM_NAME \
--image-family=$IMAGE \
--image-project=$IMAGE_PROJECT \
--boot-disk-type=$DISK_TYPE \
--boot-disk-size=$DISK_SIZE \
--machine-type=$MACHINE_TYPE \
--network=$NETWORK \
--zone=$ZONE
