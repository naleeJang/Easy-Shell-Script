#!/bin/bash

# 운영체제 타입 확인
ostype=$(cat /etc/*release| grep ID_LIKE | sed "s/ID_LIKE=//;s/\"//g")

# 운영체제가 페도라 계열일 경우
if [[ $ostype == "fedora" ]]; then
  # 설정 여부 체크
  conf_chk=$(cat /etc/pam.d/system-auth | grep 'local_users_only$' | wc -l)
  # 설정이 안되어 있으면 설정 후 설정 내용 확인
  if [ $conf_chk -eq 1 ]; then
    sed -i 's/\(local_users_only$\)/\1 retry=3 authtok_type= minlen=8 lcredit=-1 ucredit=-1 dcredit=-1 ocredit=-1 enforce_for_root/g' /etc/pam.d/system-auth
    cat /etc/pam.d/system-auth | grep '^password[[:space:]]*requisite'
  fi
# 운영체제가 데비안 계열일 경우
elif [[ $ostype == "debian" ]]; then
  # pam_pwquality.so가 설치되어 있는지 설정파일을 통해 확인
  conf_chk=$(cat /etc/pam.d/common-password | grep 'pam_pwquality.so' | wc -l)
  # 설치가 안되어 있으면 libpam-pwquality 설치
  if [ $conf_chk -eq 0 ]; then
     apt install libpam-pwquality
  fi
  # 설정 여부 체크
  conf_chk=$(cat /etc/pam.d/common-password | grep 'retry=3$' | wc -l)
  # 설정이 안되어 있으면 설정 후 설정 내용 확인
  if [ $conf_chk -eq 1 ]; then
     sed -i 's/\(retry=3$\)/\1 minlen=8 maxrepeat=3 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1 difok=3 gecoscheck=1 reject_username enforce_for_root/g' /etc/pam.d/common-password
     echo "==========================================="
     cat /etc/pam.d/common-password | grep '^password[[:space:]]*requisite'
  fi
fi
