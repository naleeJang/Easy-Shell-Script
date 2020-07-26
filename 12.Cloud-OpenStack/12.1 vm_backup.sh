#!/bin/bash
NFS_PATH="192.168.100.10:/osp16_backup"
MOUNT_PATH=/tmp/backup

# VM 목록 확인
virsh list --all

# 백업할 VM명 입력
read -p "Input vm name for backup : " vmname

# 입력받은 VM 상태 확인
vmstat=$(virsh list --all | grep -e $vmname -e "shut off" | wc -l)

# VM 상태가 running일 경우
if [[ $vmstat -eq 0 ]]; then
  # VM을 shot off 할 지 여부 확인
  read -p "$vmname is running. Do you want to shut off? (y/n) " vmresult
  # Y를 입력했으면 VM을 shutdown하고, 스크립트 재실행하고 메시지 출력
  if [[ $vmresult == "y" ]]; then
    echo "$vmname will be shut off soon"
    virsh shutdown $vmname
    echo "Please retry to run this script."
    exit;
  # N을 입력했을 경우 스크립트 종료
  else
    exit;
  fi
# VM 상태가 shut off일 경우
else
  echo "#========================"
  echo "# Make Mount Directory "
  echo "#========================"
  mkdir -p $MOUNT_PATH

  echo "#========================"
  echo "# Mount Directory to NFS "
  echo "#========================"
  mount -t nfs $NFS_PATH $MOUNT_PATH

  echo "#========================"
  echo "# Macke Backup Directory "
  echo "#========================"  
  backup_path=$MOUNT_PATH/bakup_$(date +%Y%M%d)
  mkdir -p $backup_path

  echo "#========================"
  echo "# Find vm file path "
  echo "#========================"  
  file_path=$(virsh dumpxml $vmname | grep 'source file' | sed "s/[[:blank:]]*<source file='//g" | sed "s/'\/>//g")

  echo "#========================"
  echo "# Backup vm file "
  echo "#========================"  
  cp $file_path $backup_path
  if [[ -f $backup_path/$file_path ]]; then
    echo "#============================="
    echo "# Finish backup and Start vm "
    echo "#============================="  
    virsh start $vmname

    echo "#=============="
    echo "# Umount NFS "
    echo "#=============="  
    umount $MOUNT_PATH
  fi
fi
