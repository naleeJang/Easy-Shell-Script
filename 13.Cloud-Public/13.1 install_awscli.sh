#!/bin/bash

# curl을 사용하여 awscli 패키지 다운로드
echo "awscli download"
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

# 다운로드 받은 패키지 압축해제
echo "unzip awscliv2.zip"
unzip awscliv2.zip

# 설치 프로그램 실행
echo "install aws cli"
sudo ./aws/install -i /usr/local/aws-cli -b /usr/local/bin

# 설치 확인
aws --version

