#!/bin/bash

conf_path=/etc/ssh/sshd_config

function restart_system()
{
  echo "Restart sshd"
  systemctl restart sshd
}

function selinux()
{
  # 운영체제가 레드햇 리눅스이고, port를 수정했을 경우
  if [[ $(cat /etc/*release | grep -i redhat | wc -l) > 1 ]] && [[ $1 == 1 ]]
  then
    # SELinux에 해당 port 추가
    echo "Add port $port to selinux"
    semanage port -a -t ssh_port_t -p tcp $port
  fi
}

# 환경설정 파일 백업
cp $conf_path ${conf_path}.bak.$(date +%Y%m%d)

case $1 in
  1)
  # Port 변경
  read -p "Please input port: " port
  exist_conf=$(cat $conf_path | grep -e '^#Port' -e '^Port')
  sed -i "s/$exist_conf/Port $port/g" $conf_path
  restart_system
  selinux $1
  ;;
  2)
  # PermitRootLogin 변경
  read -p "Please input PermitRootLogin yes or no: " rootyn
  exist_conf=$(cat $conf_path | grep -e '^#PermitRootLogin' -e '^PermitRootLogin')
  sed -i "s/$exist_conf/PermitRootLogin $rootyn/g" $conf_path
  restart_system
  ;;
  3)
  # PasswordAuthentication 변경
  read -p "Please input PasswordAuthentication yes or no: " pwyn
  exist_conf=$(cat $conf_path | grep -e '^#PasswordAuthentication' -e '^PasswordAuthentication')
  sed -i "s/$exist_conf/PasswordAuthentication $pwyn/g" $conf_path
  restart_system
  ;;
  4)
  # PubkeyAuthentication 변경
  read -p "Please input PubkeyAuthentication yes or no: " keyyn
  exist_conf=$(cat $conf_path | grep -e '^#PubkeyAuthentication' -e '^PubkeyAuthentication')
  sed -i "s/$exist_conf/PubkeyAuthentication $keyyn/g" $conf_path
  restart_system
  ;;
  *)
  echo "Please input with following number"
  echo "1) Port  2) PermitRootLogin  3) PasswordAuthentication  4)PubkeyAuthentication"
  echo "Usage: config-sshd.sh 2"
esac

