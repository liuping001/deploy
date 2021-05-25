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
# 目的文件夹，也可以不提供，默认为空。文件的目的地址为 dest_dir + dest
dest_dir: /tmp/test_deploy/

# 可以将所有主机定义在一个分组，执行一些机器初始化的工作
init_host:
  cmd:
    - "ls -l /tmp"

# 定义1个服务
server1:
  cp:
    - src: test.py # 只能是文件
      dest: server1/ #这里填文件夹: server1/ 。 也可以填文件:server1/test.py，但上级目录需要存在
  # cp2 指定文件中要copy的文件列表
  cp2:
    - src: ./ # 不管带不带/都表示目录
      dest: server1 # 不管带不带/都表示目录
      files:
        - test.py
  cp_t: # 模板替换配置文件
    - src: config.ini
      dest: server2/ #这里填文件夹: server1/ 。 也可以填文件:server1/test.py，但上级目录需要存在

  # start，stop，status默认会进入，dest_dir所在的文件，然后接着执行后面的命令。如果dest_dir为空，就进入用户目录了
  start: "cd server1 && nohup python test.py &"
  stop: "cd server1 && ps -ef|grep test.py|grep -v color|awk '{print $2}'|xargs kill"
  state: "cd server1 && ps -ef|grep test.py|grep -v color"

# 定义一个定时任务类型的服务
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
deploy server1 push
deploy server1 start,state
deploy server2 push,crontab
```

# 其他

### 部署crontab定时任务
部署crontab定时任务需要使用的属性：
1. cp copy普通文件
2. template 替换包含变量的配置文件
3. crontab 描述定时任务。  

对于crontab属性有以下规则：必须定义job属性。 state只能是install或remove。name是一个定时任务的索引关键字，必须定义且唯一。minute、hour、day、month、weekday等属性都是可选的，默认为"*"。 



