#!/bin/bash

# 인증
aws configure

# 이미지 정보 입력
read -p "Input image id : " imageid

# 인스턴스 타입 정보 입력
echo "== Instance Type List =="
aws ec2 describe-instance-types | grep InstanceType | grep t2
read -p "Input instance type : " instancetype

# 키페어 정보 입력
echo "== Key Pair List =="
aws ec2 describe-key-pairs | grep KeyName
read -p "Input key-pair name : " keyname

# 보안그룹 정보 입력
echo "== Security Group List =="
aws ec2 describe-security-groups | grep -e GroupName -e GroupId
read -p "Input security group id : " securitygrpid

# 서브넷 정보 입력
echo "== Subnet List =="
aws ec2 describe-subnets | grep -e SubnetId -e CidrBlock
read -p "Input subnet id : " subnetid

# EC2 인스턴스 생성
aws ec2 run-instances \
--image-id $imageid \
--count 1 \
--instance-type $instancetype \
--key-name $keyname \
--security-group-ids $securitygrpid \
--subnet-id $subnetid
