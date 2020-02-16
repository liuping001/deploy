#!/bin/sh
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
if [ "$3" = "list" ];then
    ansible localhost -m debug --extra-vars "@${CUR_DIR}/$1" -a "msg={{ deploy_info.keys()|list}}" 2>&1 |grep -v -P 'PLAY|WARNING|localhost|\[|\]|\}'
    exit
fi
if [ $# -lt 4 ];then
    usage
    exit
fi

for server in ${@:4};
do
    # echo $server
    export ANSIBLE_FORCE_COLOR=true
    ansible-playbook -i ${CUR_DIR}/$2 ~/.bin/task.yml --tags="$3" -e "server_name=$server server_define_file=${CUR_DIR}/$1 work_dir=${CUR_DIR}" |grep -v -P 'PLAY|WARN'
done;
 
