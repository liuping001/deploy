# 简介
这是一个通用的服务器部署工具,使用的方式如example所示：
1. 通过在deploy/test/group_vars/all.yml配置文件中描述每个服务的部署行为，如push,start,stop,state,cmd,crontab
2. 通过在deploy/test/inventory文件中描述每个服务需要部署到那些机器上
3. 使用"deploy server1,server2 action1,action2" 进行部署。例如 
> deploy server1 push  
> deploy server1 start

注：
* 运行deploy命令需要在有inventory文件的目录中。例如example中的列子需要 cd example/deploy/test;  
* deploy命令会在当前文件路径上寻找deploy文件夹，如果找到/根目录还没有找到，就输出"not find dir deploy/"  
* 如果有多套环境，deploy可以创建表示不同环境的文件夹。如：test、dev、live  
* 每个环境中在inventory文件中定义机器分组的信息，在group_vars文件夹中定义组变量文件，all.yml表示默认组变量，可以在具体的组中覆盖同名变量  

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

# 全局的传文件是否备份的开关
backup: no

# 可以将所有主机定义在一个分组，执行一些机器初始化的工作
init_host:
  cmd:
    - "ls -l /tmp"

# 定义1个服务
server1:
  backup: yes # 服务的传文件是否备份的开关
  push:
    - src: test.py # 只能是文件
      dest: server1/ #这里填文件夹: server1/ 。 也可以填文件:server1/test.py，但上级目录需要存在
  # files 指定文件夹中要copy的文件列表
    - src: ./ # 不管带不带/都表示目录
      dest: server1 # 不管带不带/都表示目录
      files:
        - test.py
  # 模板替换配置文件
    - src: config.ini
      dest: server1/ #这里填文件夹: server1/ 。 也可以填文件:server1/test.py，但上级目录需要存在
      template: yes

  # start，stop，status默认会进入，dest_dir所在的文件夹，然后接着执行后面的命令。如果dest_dir为空，就进入用户目录了
  start: "cd server1 && nohup python test.py &"
  stop: "cd server1 && ps -ef|grep test.py|grep -v color|grep -v grep|awk '{print $2}'|xargs kill"
  state: "cd server1 && ps -ef|grep test.py|grep -v color|grep -v grep"
#  start_file: server1/start.sh

# 定义一个定时任务类型的服务
server2:
  push:
    - src: hello.sh
      dest: /tmp/server2/
  crontab:
    - {state: install, name: hello, minute: 5, hour: 1, job: /tmp/server2/hello.sh}
```
* 服务属性列表

属性|作用|子属性|相关action  
-|-|-|-
push|copy文件到目标机器|src、dest、files、template|push 
cmd|运行指令，可用于启动服务前的初始化工作|shell命令|cmd
start|自定义启动程序的命令||start
stop|自定义停止程序的命令||stop
state|自定义查询程序是否启动的命令||state
start_file|未定义start、stop、state属性时使用||start、stop、state|
crontab|安装定时任务|name、minute、hour、day、month、weekday、job|install、remove

**关于start_file属性的说明**
> start_file: server1/start.sh
> 1. 定义了start_file，且没定义 start、stop、state：  
> start、stop、state默认行为为start_file start; start_file stop; start_file state;
> 2. 定义了start、stop、state属性。start_file对应的行为将会被代替    
> 3. 如果没有定义start_file，也没有定义 start、stop、state。将会使用默认的start_file=~/.bin/service.sh。所以需要安装~/.bin/service.sh到每一个机器下面,通过deploy server init安装，
> 同时还需要定义exe_file, args连个参数，此时 start、stop、state对应命令为~/.bin/service.sh start {{exe_file}} {{args}}; ~/.bin/service.sh stop {{exe_file}};
> ~/.bin/service.sh state {{exe_file}} 

### 定义机器
* 在inventory中定义每个服务需要部署到那些host上
```yaml
# 描述连接一个机器的方式
127.0.0.1 ansible_ssh_host=127.0.0.1 ansible_ssh_user=liuping ansible_ssh_pass=liuping

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
对于crontab属性有以下说明：
* 必须定义job属性。 
* name是一个定时任务的索引关键字，必须定义且唯一。
* minute、hour、day、month、weekday等属性都是可选的，默认为"*"。 



