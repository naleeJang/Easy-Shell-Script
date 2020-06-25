#!/bin/bash

# 변수에 마운트 대상 NFS 경로 및 디렉토리 저장 
nfs_server="nfs.host01:/temp"
nfs_dir=/nfs_temp

# 마운트할 디렉토리가 있는지 체크후 없으면 디렉토리 생성
if [ ! -d $nfs_dir ]; then mkdir -p $nfs_dir; fi

# 해당 NFS와 디렉토리 마운트
mount -t nfs $nfs_server $nfs_dir

# 마운트 정보에서 마운트 타입과 옵션 추출
nfs_type=$(mount | grep $nfs_dir | awk '{print $5}')
nfs_opt=$(mount | grep $nfs_dir | awk '{print $6}' | awk -F ',' '{print $1","$2","$3}')

# 추출한 마운트 정보를 조합하여 /etc/fstab에 설정
echo "$nfs_server  $nfs_dir  $nfs_type  ${nfs_opt:1}  1  1" >> /etc/fstab

# 설정한 /etc/fstab 내용 확인
cat /etc/fstab | grep $nfs_dir 

# 마운트 된 디렉토리 정보 확인
df -h | grep $nfs_dir
