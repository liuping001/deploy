#!/bin/bash
set -e
usage()
{
    echo ""
    echo "Usage: deploy server1,server2 action1,action2"
    echo "example:"
    echo "    deploy server1,server2 push"
    echo "    deploy server1 cmd,start"
}

# 获取额外参数
other_args()
{
  while getopts "i:e:" option
  do
     case ${option} in
       i)
          inventory="${OPTARG}"
        ;;
       e)
          app_vars="${OPTARG}"
        ;;
     esac
  done
}

# 获取额外参数
inventory="inventory"
app_vars=""
other_args "${@:3}"

current_dir=`pwd`
if [ ! -f ${current_dir}/${inventory} ];then
  echo "file:"${inventory}" not exist in current dir"
  exit 1
fi

# 获取当前工程根目录
proj_dir=`pwd`
find_work_dir_count=10
while [ ! -d $proj_dir/deploy ]
do
    proj_dir=${proj_dir}/..
    ((find_work_dir_count--))
    if [ $find_work_dir_count == 0 ];then
        echo "not find dir deploy/"
        exit
    fi
done
deploy_dir=${proj_dir}/deploy

proj_dir=`cd $proj_dir && pwd`
deploy_dir=`cd $deploy_dir && pwd`

deploy_vars_file=~/.deploy_vars.yml
if [ -f ${current_dir}/deploy_vars.yml ];then
  deploy_vars_file=${current_dir}/deploy_vars.yml
fi

echo -e "\033[32m"
echo "info: "
echo "-> project path [$proj_dir]"
echo "-> deploy path [$deploy_dir]"
echo "-> deploy vars path [$deploy_vars_file]"

if [ $# -lt 2 ];then
  echo -e "\033[0m"
  usage
  exit
fi

server_list=$(echo $1 | tr "," "\n")
action_list=$(echo $2 | tr "," "\n")

echo "-> server: "$server_list
echo "-> action: "$action_list

echo -e "\033[0m"

for server in ${server_list}
do
  for action in ${action_list}
    do
      ansible-playbook  -i ${current_dir}/${inventory} ~/.bin/task.yml --tags=$action -e "server_name=$server work_dir=${proj_dir} deploy_vars_file=${deploy_vars_file} ""$app_vars"
    done
done
