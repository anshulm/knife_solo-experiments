#!/bin/sh

# check for correct number of arguments
if [ $# -ne 3 ]; then
  echo "Usage: $0 <user> <ip> <port>"
  exit 1
fi

# set variables
USER=$1
IP=$2
PORT=$3

# upload key for root - need to have a root user. Check EC2 specific changes
ssh-copy-id -i ~/.ssh/id_rsa.pub -p $PORT vagrant@$IP

# install chef
cd chef && knife solo prepare -p $PORT vagrant@$IP
#cd chef

# execute the run list
knife solo cook -p $PORT vagrant@$IP

# upload key for user
ssh-copy-id -i ~/.ssh/id_rsa.pub -p $PORT $USER@$IP

# upload app
cd ../.. && cap production deploy

# restart nginx
ssh -p $PORT -t $USER@$IP 'sudo service nginx restart'
