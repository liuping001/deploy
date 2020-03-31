#!/bin/bash
usage()
{
    echo ""
    echo "Usage: deploy [server.yml] [host.txt] [start] [server_name]... "
    echo ""
    echo "example:"
    echo "    deploy server.yml host.txt push server1 server2"
    echo ""
    echo "all action:"
    echo "    deploy server.yml host.txt [push]     # copy_file template"
    echo "    deploy server.yml host.txt [init]     # init_cmd"
    echo "    deploy server.yml host.txt [start]    # supervisor"
    echo "    deploy server.yml host.txt [stop]     # supervisor"
    echo "    deploy server.yml host.txt [status]   # supervisor"
    echo "    deploy server.yml host.txt [restart]  # supervisor"
    echo "    deploy server.yml host.txt [install]  # crontab"
    echo "    deploy server.yml host.txt [remove]   # crontab"

}

# 获取当前工程根目录
WORK_DIR=`pwd`
find_work_dir_count=10
while [ ! -d $WORK_DIR/deploy ]
do
    WORK_DIR=${WORK_DIR}/..
    echo $WORK_DIR
    ((find_work_dir_count--))
    if [ $find_work_dir_count == 0 ];then
        echo "not find dir deploy/"
        exit
    fi
done
WORK_DIR=${WORK_DIR}/deploy
echo "current work dir is [$WORK_DIR]"

patten=".*"
if [ "$4" = "-P" ];then
    patten=$5
fi

if [ $# -lt 3 ];then
    usage
    exit
fi
if [ "$3" = "list" ];then
    ansible localhost -m debug --extra-vars "@${WORK_DIR}/$1" -a "msg={{ deploy_info.keys()|list}}" 2>&1 |grep -o -P "\".*\""|grep -v "\"msg\"" |grep -P "$patten"
    exit
fi

if [ $# -lt 4 ];then
    usage
    exit
fi

if [ "$4" = "-P" ];then
    if [ $# -lt 5 ];then
        usage
        exit
   fi
   server_list=`ansible localhost -m debug --extra-vars "@${WORK_DIR}/$1" -a "msg={{ deploy_info.keys()|list}}" 2>&1 |grep -o -P "\".*\""|grep -v "\"msg\"" |grep -P "$patten"`
else
   server_list=${@:4}
fi

for server in $server_list;
do
    # echo $server
    export ANSIBLE_FORCE_COLOR=true
    ansible-playbook -i ${CUR_DIR}/$2 ~/.bin/task.yml --tags="$3" -e "server_name=$server server_define_file=${WORK_DIR}/$1 work_dir=${WORK_DIR}" |grep -v -P 'PLAY|WARN'
done;
 
