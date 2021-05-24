#!/bin/bash

usage()
{
    echo ""
    echo "Usage: deploy server1,server2 action1,action2"
    echo "example:"
    echo "    deploy server,server2 push"
    echo "    deploy server,server2 push"
    echo "    deploy hello push,cmd"
}

if [ $# -lt 2 ];then
    usage
    exit
fi

# 获取当前工程根目录
current_dir=`pwd`
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

echo "info: "
echo "-> deploy dir is [$deploy_dir]"
echo "-> project dir is [$proj_dir]"

server_list=$(echo $1 | tr "," "\n")
action_list=$(echo $2 | tr "," "\n")

echo "-> action: "$action_list
echo "-> server: "$server_list

for server in ${server_list}
do
  for action in ${action_list}
    do
      ansible-playbook -i ${current_dir}/inventory ~/.bin/task.yml --tags="$2" -e "server_name=$server work_dir=${proj_dir}"
    done
done
