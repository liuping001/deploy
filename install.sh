#!/bin/sh
mkdir -p ~/.bin
cp d.sh ~/.bin/deploy
cp task.yml ~/.bin/task.yml
chmod +x ~/.bin/deploy
echo 'export PATH=~/.bin:$PATH' >> ~/.bashrc
source ~/.bashrc
