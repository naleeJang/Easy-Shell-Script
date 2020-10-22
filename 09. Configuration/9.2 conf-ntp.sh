#!/bin/bash

ip=""
netmask=""
conf=""
service=""

# IP CIDR을 NetMask로 변경함.
function transfer_iprange()
{
    ip=${1%/*}
    if [[ ${1#*/} == 16 ]]; then netmask="255.255.0.0"; fi
    if [[ ${1#*/} == 23 ]]; then netmask="255.255.254.0"; fi
    if [[ ${1#*/} == 24 ]]; then netmask="255.255.255.0"; fi
    if [[ ${1#*/} == 28 ]]; then netmask="255.255.240.0"; fi
}

if [[ -n $1 ]]; then
  # 정규 표현식을 이용하여 IP 범위를 정상적으로 입력했는지 확인
  range_chk=$(echo "$1" | grep -E "^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.0/[0-9]{2}$" | wc -l)
  # 정규 표현식과 다르다면 메시지를 출력하고 스크립트 종료
  if [[ range_chk -eq 0 ]]; then
    echo "This ip cidr is wrong. Please input the right ip cidr."
    exit;
  fi
fi

# chrony가 설치되어 있는지 ntp가 설치되어 있는지 환경설정 파일을 통해 확인
if [[ -f /etc/chrony.conf ]]; then 
  conf=/etc/chrony.conf
  service=chronyd.service
elif [[ -f /etc/ntp.conf ]]; then 
  conf=/etc/ntp.conf
  service=ntpd.service
fi

# 서버 주소 변경
sed -i "s/^server/#server/g" $conf
sed -i "/^#server 3/ a \server 127.127.1.0" $conf
  
# 파라메터로 IP가 있으면  allow 설정
if [[ -n $1 && -f /etc/chrony.conf ]]; then
    sed -i "/^#allow/ a \allow $1" $conf
# 환경설정 파일이 ntp.conf 일 경우
elif [[ -n $1 && -f /etc/ntp.conf ]]; then
    transfer_iprange $1
    restrict="restrict $ip mask $netmask nomodify notrap"
    sed -i "/^#restrict/ a \restrict $restrict" $conf
fi

# 서비스 재시작  
echo "systemctl restart $service"
systemctl restart $service

# 포트 추가
echo "firewall-cmd --add-service=ntp"
firewall-cmd --add-service=ntp
echo "firewall-cmd --add-service=ntp --permanant"
firewall-cmd --add-service=ntp --permanant
