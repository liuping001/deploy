set -e
action=$1

case $action in
"help")
  echo '通用的启动程序脚本，支持重入'
  echo '包含操作: start、state、stop'
  echo '  service.sh start exe args'
  echo '  service.sh state exe'
  echo '  service.sh stop'
  exit 0
;;
esac

if test ! -x "$2"; then
  echo "不是可执行的文件:$2"
  exit 1
fi
exe_path=$(readlink -f $2)
cd $(dirname $exe_path)

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
  log="/tmp/std_"$(basename $exe_path)"_"$(date +%Y-%m-%d_%H-%M-%S)".log"
  nohup $exe_path ${@:3} > $log 2>&1 &
  sleep 3
  if [ $(state) == "true" ];then
    echo "启动成功"
    exit 0
  fi
  echo "启动中..."
  exit 1
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
  sleep 3
  if [ $(state) == "false" ];then
    echo "停止成功"
    exit 0
  fi
  echo "停止中..."
  exit 1
  ;;
"state")
  set +e
  msg=$(ps -ef|grep $exe_path|grep -v grep |grep -v color)
  echo $msg
  exit 0
  ;;
*)
  echo "没有匹配到action"
  exit 1
  ;;
esac