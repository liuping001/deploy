# 简介
这是一个通用的服务器部署工具,使用的方式如example所示：
1. 通过在server.yml配置文件中描述每个服务的部署行为，如cp, template, cmd
2. 通过在host.ini文件中描述每个服务需要部署到那些机器上
3. 使用"run.sh action1,action2 server1,server2 [inventory]" 进行部署。例如 "run.sh server1 cp inventory"

# 安装依赖
```shell script
sudo yum install ansible -y
```
# 安装deploy
```
./install.sh
source ~/.bashrc
```
# 使用
### 在server.yml定义部署服务的配置项。
例如：
```yaml
  # 普通服务
  server1:
    cp: # 支持数组
      - src: /tmp/test.py
        dest: /tmp/server_1.py
    cmd: # 支持数组
      - "mkdir -p /tmp/server_1_log"
    
  #定时任务
  server2:
    cp:
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
run.sh cp server1,server2 server.yml inventory
run.sh cp,cmd server1 server.yml host.ini
run.sh cp,crontab server2 server.yml host.ini
```
# deploy详细介绍
### 服务属性列表

属性|作用|子属性  
-|-|- 
cp|copy文件到目标机器|src、dest
cp2|copy文件到目标机(指定目录)|src、dest、files
cp_t|template替换配置文件中的变量并copy到目标机器|src、dest  
cmd|运行指令|shell命令
crontab|安装定时任务|state、name、minute、hour、day、month、weekday、job

### 自定义service.sh脚本来启动服务
```
  #普通服务
  server1:
    copy_file: # 支持数组
      - src: /tmp/server_1
        dest: /tmp/server_1
      - src: /tmp/service.sh
        dest: /tmp/service.sh
    start: "cd /tmp/ && service.sh start server_1"
    stop: "cd /tmp/ && service.sh stop server_1"
    status: "cd /tmp/ && service.sh status server_1"
```

### 部署crontab定时任务
部署crontab定时任务需要使用的属性：
1. copy_file copy普通文件
2. template 替换包含变量的配置文件
3. crontab 描述定时任务。  

对于crontab属性有以下规则：必须定义job属性。 state只能是install或remove。name是一个定时任务的索引关键字，必须定义且唯一。minute、hour、day、month、weekday等属性都是可选的，默认为"*"。 



