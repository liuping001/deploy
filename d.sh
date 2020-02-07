#!/bin/sh
usage()
{
    echo "Usage: $0 [server_define.yml] [host.txt] [start] [server_name]... "
    echo "example:"
    echo "    $0 server_define.yml host.txt push server1 server2"
}
CUR_DIR=`pwd`
if [ $# -lt 4 ];then
    usage
    exit
fi

for server in ${@:4};
do
    # echo $server
    export ANSIBLE_FORCE_COLOR=true
    ansible-playbook -i $2 ~/.bin/task.yml --tags="$3" -e "server_name=${CUR_DIR}/$server server_define_file=${CUR_DIR}/$1" |grep -v -P 'PLAY|unreachable|WARN'
done;
 
