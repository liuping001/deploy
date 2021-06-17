#!/bin/bash
set -e
usage()
{
    echo ""
    echo "Usage: deploy server1,server2 action1,action2"
    echo "example:"
    echo "    deploy server1,server2 push,start"
    echo "    deploy server1 push -e 'key=value'"
    echo "    deploy server1 push -i inventory "
    echo "    deploy server1 push -v # 显示info"
    echo "    deploy server1 push -s # 简化输出 short print"
}

# 获取额外参数
other_args()
{
  while getopts "i:e:vs" option
  do
     case ${option} in
       i)
          inventory="${OPTARG}"
        ;;
       e)
          app_vars="${OPTARG}"
          ;;
       v)
         info="yes"
        ;;
       s)
         short_print="yes"
         ;;
     esac
  done
}

# 获取额外参数
inventory="inventory"
app_vars=""
info=""
short_print=""
other_args "${@:3}"

current_dir=`pwd`
# 获取当前工程根目录
proj_dir=`pwd`
find_work_dir_count=10
while [ ! -d $proj_dir/deploy ]
do
    proj_dir=${proj_dir}/..
    ((find_work_dir_count--))
    if [ $find_work_dir_count == 0 ];then
        echo "not find dir deploy/"
        exit 1
    fi
done
deploy_dir=${proj_dir}/deploy

proj_dir=`cd $proj_dir && pwd`
deploy_dir=`cd $deploy_dir && pwd`

deploy_vars_file=~/.deploy_vars.yml
if [ -f ${current_dir}/deploy_vars.yml ];then
  deploy_vars_file=${current_dir}/deploy_vars.yml
fi


if [ $# -lt 2 ];then
  usage
  exit 1
fi

if [ ! -f ${current_dir}/${inventory} ];then
  echo "file:"${inventory}" not exist in current dir"
  exit 1
fi

server_list=$(echo $1 | tr "," "\n")
action_list=$(echo $2 | tr "," "\n")

if [ "$info" == "yes" ];then
  echo -e "\033[32m"
  echo "info: "
  echo "-> project path [$proj_dir]"
  echo "-> deploy path [$deploy_dir]"
  echo "-> deploy vars path [$deploy_vars_file]"
  echo "-> server: "$server_list
  echo "-> action: "$action_list
  echo -e "\033[0m"
fi

for server in ${server_list}
do
  for action in ${action_list}
    do
      if [ "$short_print" == "yes" ];then
        export ANSIBLE_FORCE_COLOR=true #管道过滤的时候保留颜色
        ansible-playbook  -i ${current_dir}/${inventory} ~/.bin/task.yml --tags=$action -e "server_name=$server work_dir=${proj_dir} deploy_vars_file=${deploy_vars_file} ""$app_vars" | \
        grep -v 'PLAY RECAP' | grep -v 'WARN \['| grep -v 'TASK \[' | grep -v 'PLAY \['| grep -v ^$
      else
        ansible-playbook  -i ${current_dir}/${inventory} ~/.bin/task.yml --tags=$action -e "server_name=$server work_dir=${proj_dir} deploy_vars_file=${deploy_vars_file} ""$app_vars"
      fi
    done
done
