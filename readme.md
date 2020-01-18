# 简介
这是一个通用的服务器部署工具。  
1. 通过在group_vars/all配置文件中描述每个服务的部署行为，如[push,start,stop,restart]
2. 通过在host文件中描述每个服务需要部署到那些机器上
3. 使用"d.sh host文件 对服务的行为 服务列表" 进行部署。例如 "./d.sh host.txt push server1"
 
# 安装依赖
```shell script
sudo yum install ansible -y
```

# 使用
### 在group_vars/all定义部署服务的配置项
```yaml
deploy_info:
  server1:
    push:
      - src: /tmp/1.txt
        dest: /tmp/1_1.txt
    start: "cd / && cat /tmp/1_1.txt"
    stop: "cd / && rm /tmp/1_1.txt"
    restart: "cd / && ls -l"

  server2:
    push:
      - src: /tmp/2.txt
        dest: /tmp/2_1.txt  
    start: "cd / && cat /tmp/1_1.txt"
    stop: "cd / && rm /tmp/2_1.txt"
    restart: "cd / && ls -l"

```
对服务可以进行的行为有[push、start、stop、restart]
### 定义每个服务需要部署到那些host上
```yaml
[server1]
localhost

[server2]
localhost
```

### 部署例子
```shell script
./d.sh host.txt push server1 server2 #push 启动server1、server2需要的文件
./d.sh host.txt start server1 server2 #启动 server1、server2
```