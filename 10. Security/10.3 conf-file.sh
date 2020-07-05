#!/bin/bash

# Sticky bit가 설정된 경로 검색
echo "=== SUID, SGID, Sticky bit Path ==="
s_file=$(find / -xdev -perm -04000 -o -perm -02000 -o -perm 01000 2>/dev/null | grep -e 'dump$' -e 'lp*-lpd$' -e 'newgrp$' -e 'restore$' -e 'at$' -e 'traceroute$')
find / -xdev -perm -04000 -o -perm -02000 -o -perm 01000 2>/dev/null | grep -e 'dump$' -e 'lp*-lpd$' -e 'newgrp$' -e 'restore$' -e 'at$' -e 'traceroute$' | xargs ls -dl

# World Writable 경로 검색
echo -e "\n=== World Writable Path ==="
w_file=$(find / -xdev -perm -2 -ls | grep -v 'l..........' | awk '{print $NF}')
find / -xdev -perm -2 -ls | grep -v 'l..........' | awk '{print $NF}' | xargs ls -dl

echo ""
read -p "Do you want to change file permission(y/n)? " result

if [[ $result == "y" ]]; then

  # Sticky bit 경로 권한 변경
  echo -e "\n=== Chmod SUID, SGID, Sticky bit Path ==="
  for file in $s_file; do
    echo "chmod -s $file"
    chmod -s $file
  done
  # Writable 경로 권한 변경
  echo -e "\n=== Chmod World Writable Path ==="
  for file in $w_file; do
    echo "chmod o-w $file"
    chmod o-w $file
  done

  # Sticky bit 경로 변경결과 조회
  echo -e "\n=== Result of Sticky bit Path ==="
  for file in $s_file; do
    ls -dl $file
  done
  # Writable 경로 변경결과 조회
  echo -e "\n=== Result of World Writable Path ==="
  for file in $w_file; do
    ls -dl $file
  done
# 파일권한 변경을 원하지 않을 경우
elif [[ $result == "n" ]]; then
  exit
# 파일권한 변경여부 질의에 아무것도 입력하지 않았을 경우 
elif [[ -z $result ]]; then
  echo "Yon didn't have any choice. Please check these files for security."
  exit
# 파일권한 변경여부 질의에 아무 글자나 입력했을 경우
else
  echo "You can choose only y or n."
  exit 
fi 
