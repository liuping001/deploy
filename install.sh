#!/bin/sh
mkdir -p ~/.bin
cp d.sh ~/.bin/d.sh
cp task.yml ~/.bin/task.yml
chmod +x ~/.bin/d.sh
echo 'export PATH=~/.bin:$PATH' >> ~/.bashrc
source ~/.bashrc
