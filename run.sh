usage()
{
    echo ""
    echo "Usage: run.sh action1,action2 server1,server2 [server.yml] [host.ini]"
    echo "参数说明:"
    echo "    如果不传 server.yml host.ini。默认文件名就是 server.yml、host.ini"
    echo "    如果只传 server.yml。host.ini 默认文件名就是 host.ini"
    echo "example:"
    echo "    run.sh push server,server2"
    echo "    run.sh push server,server2 server_all.yml"
    echo "    run.sh push,cmd hello server_hello.yml host_hello.ini"
}

if [ $# -lt 2 ];then
    usage
    exit
fi

action_list=$(echo $1 | tr "," "\n")
server_list=$(echo $2 | tr "," "\n")
server_define=server.yml
host_define=host.ini

if [ $# -ge 3 ];then
	server_define=$3
fi
if [ $# -ge 4 ];then
	host_define=$4
fi

echo "-> action: "$action_list
echo "-> server: "$server_list
echo "-> server_define: "$server_define
echo "-> host_define: "$host_define

for server in ${server_list}
do
  for action in ${action_list}
    do
      deploy $server_define $host_define $action $server
    done
done

#deploy server.yml host.ini copy_nb,cmd,fetch server

