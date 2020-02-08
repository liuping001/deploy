# 简介
这是一个通用的服务器部署工具。  
1. 通过在server_define.yml配置文件中描述每个服务的部署行为，如[push, init_cmd]
2. 通过在host.txt文件中描述每个服务需要部署到那些机器上
3. 使用"d.sh server_define.yml host.txt 对服务的行为 服务列表" 进行部署。例如 "deploy server_define.yml host.txt push server1"
 
# 安装依赖
```shell script
sudo yum install ansible -y
sudo yum install supervisor -y
```
# 安装deploy
```
./install.sh
```

# 使用   
### 在test_server_define.yml定义部署服务的配置项
```yaml
deploy_info:
  init_host:
      - src: example/supervisor.conf
        dest: /etc/supervisord.d/my_server.conf

  server1:
    push: # 支持数组
      - src: /tmp/test.py
        dest: /tmp/server_1.py
    init_cmd: # 支持数组
      - "mkdir -p /tmp/server_1_log"
    supervisor_conf: /etc/supervisord.conf
  #定时任务
  server3:
    push:
      - src: example/hello.sh
        dest: /tmp/hello.sh
    crontab:
      - {state: install, name: hello, minute: 5, hour: 1, job: /tmp/hello.sh}

```
### 以下列出了server的所有行为以及其对应的属性。
action|属性
-|-
push|push
init|init_cmd
start|
stop|
restart|
status|
install|crontab
remove|crontab

### 定义每个服务需要部署到那些host上
```yaml
127.0.0.1 ansible_ssh_user=liuping ansible_ssh_pass=liuping ansible_sudo_pass=liuping
[server1]
127.0.0.1
[server2]
127.0.0.1
```

### 部署例子
* 对服务可以进行的行为有[push, init_cmd, start,stop,restart, status]
```shell script
deploy example/test_server_define.yml example/host.txt push server1 server2 #push 启动server1、server2需要的文件
deploy example/test_server_define.yml example/host.txt init_cmd server1 server2 # init cmd
deploy example/test_server_define.yml example/host.txt start server1 server2 #启动 server1、server2
```
