#!/bin/bash

ostype=$(cat /etc/*release| grep ID_LIKE | sed "s/ID_LIKE=//;s/\"//g")

# 운영체제가 Fedora 계열인지 Debian 계열인지 체크
if [[ $ostype == "fedora" ]]; then
    # 구글 클라우드 SDK 저장소 추가
  echo "== Add gcloud SDK repository =="
  sudo tee -a /etc/yum.repos.d/google-cloud-sdk.repo << EOM
[google-cloud-sdk]
name=Google Cloud SDK
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOM

  # 구글 클라우드 SDK 설치
  echo "== Install gcloud SDK =="
  sudo yum install google-cloud-sdk

  # gcloud init 실행
  echo "== Exec gcloud init =="
  gcloud init

elif [[ $ostype == "debian" ]]; then

  # 클라우드 SDK 배포 URI 추가
  echo "== Add gcloud sdk uri =="
  echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

  # 패키지 apt-transport-https 설치
  echo "== Install apt-transport-https =="
  sudo apt-get install apt-transport-https ca-certificates gnupg

  # 구글 클라우드 공개키 가져오기
  echo "== Getting gcloud key =="
  curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

  # 구글 클라우드 SDK 설치
  echo "== Install gcloud SDK =="
  sudo apt-get update && sudo apt-get install google-cloud-sdk

  # gcloud init 실행
  echo "== Exec gcloud init =="
  gcloud init

fi
