#!/bin/sh
usage()
{
    echo "Usage: $0 [host.txt] [start] [server_name]... "
    echo "example:"
    echo "\t$0 host.txt push server1 server2"
}

if [ $# -lt 3 ];then
    usage
    exit
fi

for server in ${@:3};
do
    # echo $server
    ansible-playbook -i $1 task.yml --tags="$2" -e "server_name=$server"
done;
 
