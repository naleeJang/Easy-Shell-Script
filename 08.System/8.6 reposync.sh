#!/bin/bash

# 레파지토지 목록을 입력받지 않고, 파일에 직접 입력해도 됨
repolist=$1
repopath=/var/www/html/repo/
osversion=$(cat /etc/redhat-release | awk '{print $(NF-1)}')

# 레파지토리 입력이 없으면 메시지를 보여주고 스크립트 종료
if [[ -z $1 ]]; then
  echo "Please input repository list. You can get repository from [yum repolist]"
  echo "Rhel7 Usage: reposync.sh \"rhel-7-server-rpms\""
  echo "Rhel8 Usage: reposync.sh \"rhel-8-for-x86_64-baseos-rpms\""
  exit;
fi

# 운영체제 버전에 따라 입력한 레포지토리만큼 동기화를 함.
for repo in $repolist; do
  # OS가 Rhel7일 경우
  if [ ${osversion:0:1} == 7 ]; then
    reposync --gpgcheck -l -n --repoid=$repo --download_path=$repopath
  # OS가 Rhel8일 경우
  elif [ ${osversion:0:1} == 8 ]; then
    reposync --download-metadata --repo=$repo -p $repopath
  fi
  # 해당 디렉토리를 레파지토리화한다.
  createrepo $repopath$repo
done
