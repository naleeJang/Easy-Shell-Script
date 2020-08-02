#!/bin/bash

# 이미지 경로를 입력받음.
read -p "Please input image path : " imgpath

# 이미지가 해당 경로에 있는지 확인
if [[ -f $imgpath ]]; then

  # 업로드할 이미지명을 입력받음.
  read -p "Please input image name : " imgname  

  # 인증 파일 export
  source ~/adminrc

  # CLI을 이용한 이미지 업로드
  openstack image create \
  --file $imgpath \
  --container-format bare \
  --disk-format $(ls $imgpath | awk -F . '$NF == "qcow2" ? type="qcow2" : type="raw" {print type}') \
  --public \
  $imgname
  
else
  # 이미지가 없을 경우 에러 메시지 출력 후 스크립트 종료
  echo "This is no image. Please try to run the script again."
  exit;
fi
