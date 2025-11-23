#!/bin/bash

#PWD=`pwd`

source ~/source/bgm-archive-gre-sh/env.sh

#banned_group=("adc_zero" "guiwubangumi" "kink" "liujun" "witness")
banned_group=("adc_zero" "guiwubangumi" "kink" "witness" "jz" "china_666" "xuesaiqiangban" "ceui111")
banned_file=~/source/bgm-archive-gre/group/bn.txt
time_hour=`date -Is -u | awk -F'T' '{printf $2}' | awk -F: '{printf $1}'`

echo time_hour $time_hour

[ $time_hour -ne '20'  ] && exit 1

> $banned_file

for i in  ${banned_group[@]};do
	echo checking $i
	tmpfile=`mktemp`
	#echo $E_BGM_COOKIE_FILE
	#echo $E_BGM_UA
	curl -sL -b $E_BGM_COOKIE_FILE -A "$E_BGM_UA" --output $tmpfile "https://bgm.tv/group/$i"
	topic_list=(`grep -v '>Mobile' $tmpfile |  grep -Po '(?<=href="/group/topic/)[0-9]+(?!">Mobile)' | sort -rn | uniq`)
	echo ${topic_list[@]}
	printf "%s\n" "${topic_list[@]}" >> $banned_file
	rm -rf $tmpfile
	sleep 1
done

# filter empty line
echo ------ before sort ----
cat $banned_file
echo ---- sorting -----
#cat $banned_file | awk NF | sort -rn > $banned_file
echo ----- after sort ----
cat $banned_file
