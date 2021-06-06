action=$1
exe=$(pwd)/$2
exe_path=$(readlink -f $exe)

function state() {
  exist=$(ps -ef|grep $exe_path|grep -v grep |grep -v color|wc -l)
  if [ $exist -le 0 ]; then
    echo "false"
    return
  fi
  echo "true"
}

case $action in
"start")
  if [ $(state) == "true" ];then
    echo "已经启动过了"
    exit 0
  fi
  nohup $exe_path ${@:3} > /dev/null 2>&1 &
  ;;
"stop")
  if [ $(state) == "false" ];then
    echo "已经停止过了"
    exit 0
  fi
  pid_list=$(ps -ef|grep $exe_path|grep -v grep |grep -v color|awk '{print $2}')
  for pid in ${pid_list}
  do
    kill $pid
  done
  ;;
"state")
  msg=$(ps -ef|grep $exe_path|grep -v grep |grep -v color)
  echo $msg
  exit 0
  ;;
*)
  echo "没有匹配到action"
  exit 1
  ;;
esac