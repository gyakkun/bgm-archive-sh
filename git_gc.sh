#!/bin/bash

## WARNING: NOT IN USED ##

PWD=`pwd`

source ~/source/bgm-archive-gre-sh/env.sh

time_hour=`date -Is -u | awk -F'T' '{printf $2}' | awk -F: '{printf $1}'`
time_min=`date -Is -u | awk -F'T' '{printf $2}' | awk -F: '{printf $2}'`
date_dd=`date -Is -u | awk -F'-' '{print $3}'  | awk -F'T' '{print $1}'`

echo time_hour $time_hour
echo time_min $time_min

[ $time_hour -ne '21'  ] && exit 1
[ $time_min -le '45'  ] && exit 1

cd ~/source/bgm-archive-gre
time git repack -ad
#time git gc --prune=all

cd $PWD

cd ~/source/bgm-archive-gre-json
time git repack -ad
#time git gc --prune=all








