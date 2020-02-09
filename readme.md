# 简介
这是一个通用的服务器部署工具,使用的方式如example所示：
1. 通过在server.yml配置文件中描述每个服务的部署行为，如copy_file, template, init_cmd
2. 通过在host.ini文件中描述每个服务需要部署到那些机器上
3. 使用"d.sh server.yml host.ini action server_list" 进行部署。例如 "d.sh example/server.yml example/host.ini push server1"

# 安装依赖
```shell script
sudo yum install ansible -y
```
# 安装deploy
```
./install.sh
```

# deploy详细介绍
### 服务属性列表
属性|作用|子属性
-|-|-
copy_file|copy文件到目标机器|src、dest
template|替换配置文件中的变量并copy到目标机器|src、dest
init_cmd|运行指令|
crontab|安装定时任务|state、name、minute、hour、day、month、weekday、job
supervisor_conf|指定supervisor所使用的配置文件|
### 以下列出了server的所有行为以及其对应的属性。
action|属性|描述
-|-|-
push|copy_file,template|copy服务相关文件到目标机
init|init_cmd|在服务器启动前需要运行的指令
start||启动服务
stop||关闭服务
restart||重启服务
status||查询服务状态
install|crontab|安装定时任务
remove|crontab|移除定时任务

### 部署基于supervisor的服务
部署基于supervisor的服务需要使用的属性：
1. copy_file copy普通文件
2. template 替换包含变量的配置文件
3. supervisor_conf 指定supervisor的配置文件

### 部署crontab定时任务
部署crontab定时任务需要使用的属性：
1. copy_file copy普通文件
2. template 替换包含变量的配置文件
3. crontab 描述定时任务。  

对于crontab属性有以下规则：必须定义job属性。 state只能是install或remove。name是一个定时任务的索引关键字，必须定义且唯一。minute、hour、day、month、weekday等属性都是可选的，默认为"*"。 

# 使用
### 在server.yml定义部署服务的配置项。
例如：
```yaml
deploy_info:
  server1:
    copy_file: # 支持数组
      - src: /tmp/test.py
        dest: /tmp/server_1.py
    init_cmd: # 支持数组
      - "mkdir -p /tmp/server_1_log"
    supervisor_conf: /etc/supervisord.conf
  #定时任务
  server3:
    copy_file:
      - src: example/hello.sh
        dest: /tmp/hello.sh
    crontab:
      - {state: install, name: hello, minute: 5, hour: 1, job: /tmp/hello.sh}
```

### 定义每个服务需要部署到那些host上
```yaml
# 描述连接一个机器的方式
127.0.0.1 ansible_ssh_user=liuping ansible_ssh_pass=liuping ansible_sudo_pass=liuping

[server1]
127.0.0.1

[server2]
127.0.0.1
```

### 部署例子
```shell script
deploy example/server.yml example/host.ini push server1 server2 #push 启动server1、server2需要的文件
deploy example/server.yml example/host.ini init_cmd server1 server2 # init cmd
deploy example/server.yml example/host.ini start server1 server2 #启动 server1、server2
```
