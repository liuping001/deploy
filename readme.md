# 简介
这是一个通用的服务器部署工具,使用的方式如example所示：
1. 通过在deploy/test/group_vars/all.yml配置文件中描述每个服务的部署行为，如cp, template, cmd, crontab
2. 通过在deploy/test/inventory文件中描述每个服务需要部署到那些机器上
3. 使用"deploy server1,server2 action1,action2" 进行部署。例如 "deploy server1 cp"

# 安装
* 依赖ansible
```shell script
sudo yum install ansible -y
```
* 安装deploy
```
ansible-playbook -i "localhost," -c local install.yml 
source ~/.bashrc
```
# 使用
### 定义服务
* 在all.yml定义部署服务的配置项。
例如：
```yaml
# 普通服务
server1:
  cp: # 支持数组
    - src: test.py
      dest: /tmp/server_1.py
  cmd: # 支持数组
    - "mkdir -p /tmp/server_1_log"
  
#定时任务
server2:
  cp:
    - src: hello.sh
      dest: /tmp/hello.sh
  crontab:
    - {state: install, name: hello, minute: 5, hour: 1, job: /tmp/hello.sh}
```
* 服务属性列表

属性|作用|子属性|相关action  
-|-|-|-
cp|copy文件到目标机器|src、dest|cp,push
cp2|copy文件到目标机(指定目录)|src、dest、files|cp2,push
cp_t|template替换配置文件中的变量并copy到目标机器|src、dest|cp_t, push  
cmd|运行指令|shell命令|cmd
crontab|安装定时任务|state、name、minute、hour、day、month、weekday、job|install、remove

### 定义机器
* 在inventory中定义每个服务需要部署到那些host上
```yaml
# 描述连接一个机器的方式
127.0.0.1 ansible_sudo_host=127.0.0.1 ansible_ssh_user=liuping ansible_ssh_pass=liuping

[server1]
127.0.0.1

[server2]
127.0.0.1
```
#### inventory文件
在inventory文件中需要定义出两个信息。  
  
* 1.定义所有机器的连接信息。如：
```
机器别名 ansible_ssh_host=ip ansible_ssh_user=用户名 ansible_ssh_pass=密码
```
* 2.定义机器的分组。一般我们按服务名为分组名，表示这个服务要部署到哪些机器。如：
```
[server1]
127.0.0.1
```

### 部署命令
```shell script
deploy server1,server2 cp
deploy server1 cp,cmd
deploy server2 cp,crontab
```

# 其他
### 自定义service.sh脚本来启动服务
```
#普通服务
server1:
  cp: # 支持数组
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
1. cp copy普通文件
2. template 替换包含变量的配置文件
3. crontab 描述定时任务。  

对于crontab属性有以下规则：必须定义job属性。 state只能是install或remove。name是一个定时任务的索引关键字，必须定义且唯一。minute、hour、day、month、weekday等属性都是可选的，默认为"*"。 



