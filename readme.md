# 简介
这是一个通用的服务器部署工具。  
1. 通过在server_define.yml配置文件中描述每个服务的部署行为，如[push, init_cmd, start,stop,restart, status]
2. 通过在host.txt文件中描述每个服务需要部署到那些机器上
3. 使用"d.sh server_define.yml host.txt 对服务的行为 服务列表" 进行部署。例如 "./d.sh server_define.yml host.txt push server1"
 
# 安装依赖
```shell script
sudo yum install ansible -y
```

# 使用 [example]  
### 在test_server_define.yml定义部署服务的配置项
* 每种行为定义都是可选的  
* 对服务可以进行的行为有[push, init_cmd, start,stop,restart, status]
```yaml
deploy_info:
  server1:
    push: # 支持数组
      - src: /tmp/test.py
        dest: /tmp/server_1.py
    init_cmd: # 支持数组
      - "mkdir -p /tmp/server_1_log"
    start: "nohup python /tmp/server_1.py &"
    stop: "pkill -f server_1"
    restart: "pkill -f server_1 && python /tmp/server_1.py &"
    status: "ps -ef|grep server_1|grep -v grep"

  server2:
    push:
      - src: /tmp/test.py
        dest: /tmp/server_2.py
    init_cmd: 
      - "mkdir -p /tmp/server_2_log"
    start: "nohup python /tmp/server_2.py &"
    stop: "pkill -f server_2"
    restart: "pkill -f server_2 && python /tmp/server_2.py &"
    status: "ps -ef|grep server_2|grep -v grep"

```

### 定义每个服务需要部署到那些host上
```yaml
127.0.0.1 ansible_ssh_user=liuping ansible_ssh_pass=liuping ansible_sudo_pass=liuping
[server1]
127.0.0.1
[server2]
127.0.0.1
```

### 部署例子
```shell script
./d.sh example/test_server_define.yml example/host.txt push server1 server2 #push 启动server1、server2需要的文件
./d.sh example/test_server_define.yml example/host.txt init_cmd server1 server2 # init cmd 
./d.sh example/test_server_define.yml example/host.txt start server1 server2 #启动 server1、server2
```