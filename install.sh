#!/bin/bash

mkdir -p ~/.bin

#在第一次的时候导入环境变量
if [ ! -f ~/.bin/task.yml ];then
	echo 'export PATH=~/.bin:$PATH' >> ~/.bashrc
fi

cp d.sh ~/.bin/deploy
cp task.yml ~/.bin/task.yml
cp run.sh ~/.bin/run.sh
chmod +x ~/.bin/deploy

source ~/.bashrc
