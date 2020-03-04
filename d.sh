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

CUR_DIR=`pwd`
patten=".*"
if [ "$4" = "-P" ];then
    patten=$5
fi

if [ $# -lt 3 ];then
    usage
    exit
fi
if [ "$3" = "list" ];then
    ansible localhost -m debug --extra-vars "@${CUR_DIR}/$1" -a "msg={{ deploy_info.keys()|list}}" 2>&1 |grep -o -P "\".*\""|grep -v "\"msg\"" |grep -P "$patten"
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
   server_list=`ansible localhost -m debug --extra-vars "@${CUR_DIR}/$1" -a "msg={{ deploy_info.keys()|list}}" 2>&1 |grep -o -P "\".*\""|grep -v "\"msg\"" |grep -P "$patten"`
else
   server_list=${@:4}
fi

for server in $server_list;
do
    # echo $server
    export ANSIBLE_FORCE_COLOR=true
    ansible-playbook -i ${CUR_DIR}/$2 ~/.bin/task.yml --tags="$3" -e "server_name=$server server_define_file=${CUR_DIR}/$1 work_dir=${CUR_DIR}" |grep -v -P 'PLAY|WARN'
done;
 
