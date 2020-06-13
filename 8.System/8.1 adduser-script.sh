#!/bin/bash

# 사용자 계정 및 패스워드가 입력되었는지 확인
if [[ -n $1 ]] && [[ -n $2 ]]
then

  UserList=($1)
  Password=($2)

  # for문을 이용하여 사용자 계정 생성
  for (( i=0; i < ${#UserList[@]}; i++ ))
  do
    # if문을 사용하여 사용자 계정이 있는지 확인
    if [[ $(cat /etc/passwd | grep ${UserList[$i]} | wc -l) == 0 ]]
    then
      # 사용자 생성 및 패스워드 설정
      useradd ${UserList[$i]}
      echo ${Password[$i]} | passwd ${UserList[$i]} --stdin
    else
      # 사용자가 있다고 메시지를 보여줌.
      echo "this user ${UserList[$i]} is existing."
    fi
  done

else
  # 사용자 계정과 패스워드를 입력하라는 메시지를 보여줌.
  echo -e 'Please input user id and password.\nUsage: adduser-script.sh "user01 user02" "pw01 pw02"'
fi
