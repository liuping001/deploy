#!/bin/bash
usage()
{
    echo ""
    echo "Usage: deploy [server.yml] [host.ini] [start] [server_name]... "
    echo ""
    echo "example:"
    echo "    deploy server.yml host.ini push server1 server2"
    echo ""
    echo "all action:"
    echo "    deploy server.yml host.ini [push]     # copy_file template"
    echo "    deploy server.yml host.ini [init]     # init_cmd"
    echo "    deploy server.yml host.ini [start]    # supervisor"
    echo "    deploy server.yml host.ini [stop]     # supervisor"
    echo "    deploy server.yml host.ini [status]   # supervisor"
    echo "    deploy server.yml host.ini [restart]  # supervisor"
    echo "    deploy server.yml host.ini [install]  # crontab"
    echo "    deploy server.yml host.ini [remove]   # crontab"

}

if [ $# -lt 3 ];then
    usage
    exit
fi

# 获取当前工程根目录
WORK_DIR=`pwd`
find_work_dir_count=10
while [ ! -d $WORK_DIR/deploy ]
do
    WORK_DIR=${WORK_DIR}/..
    ((find_work_dir_count--))
    if [ $find_work_dir_count == 0 ];then
        echo "not find dir deploy/"
        exit
    fi
done
WORK_DIR=${WORK_DIR}/deploy
WORK_DIR=`cd $WORK_DIR && pwd`

echo ""
echo "-> current work dir is [$WORK_DIR]"

if [ $# -lt 4 ];then
    usage
    exit 2
fi


server_list=${@:4}

for server in $server_list
do
    # echo $server
    export ANSIBLE_FORCE_COLOR=true #管道过滤的时候保留颜色
    ansible-playbook -i ${WORK_DIR}/$2 ~/.bin/task.yml --tags="$3" -e "server_name=$server server_define_file=${WORK_DIR}/$1 work_dir=${WORK_DIR}" \
     2>&1 |grep -v 'PLAY' | grep -v 'WARN' | grep -v ^$
    exit ${PIPESTATUS[0]} #获取管道的第一个命令的退出码
done
 
