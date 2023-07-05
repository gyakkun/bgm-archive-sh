#!/bin/bash

PWD=`pwd`

source ~/source/bgm-archive-sh/env.sh

topic_type=("character" "person" "ep")
time_hour=`date -Is -u | awk -F'T' '{printf $2}' | awk -F: '{printf $1}'`
date_dd=`date -Is -u | awk -F'-' '{print $3}'  | awk -F'T' '{print $1}'`

echo time_hour $time_hour
echo date_dd $date_dd

[ $time_hour -ne '19'  ] && exit 1
[ "`expr $date_dd % 7`" -ne '3' ] && exit 1


for i in  ${topic_type[@]};do
	banned_file=$E_BGM_ARCHIVE_GIT_REPO/$i/bn.txt
	[[ ! -f "$banned_file" ]] && continue
	>$banned_file
        echo checking max id of topic $i
        tmpfile=`mktemp`
	url="https://bgm.tv/$i"
	if [ "$i" == "ep" ]; then
		url="https://bgm.tv/wiki/activity?type=ep"
	fi
	echo url $url
        curl -L -b $E_BGM_COOKIE_FILE -A "$E_BGM_UA" --output $tmpfile "$url"
        max_id=(`grep -Po '(?<=href="/'$i'/)[0-9]+' $tmpfile | sort -rnu | head -n1`)
	echo max_id $max_id
	cd $E_BGM_ARCHIVE_JSON_GIT_REPO/$i
	pwd
	folder_1=`ls | sort -rn | head -n1`
	cd $E_BGM_ARCHIVE_JSON_GIT_REPO/$i/$folder_1
	pwd
	folder_2=`ls | sort -rn | head -n1`
	cd $E_BGM_ARCHIVE_JSON_GIT_REPO/$i/$folder_1/$folder_2
	pwd
	ls | sort -rn | head -n1 | awk -F'.' '{print $1}'
	pwd
	cur_max_id=`ls | sort -rn | head -n1 | awk -F'.' '{print $1}'`
	echo cur max id $cur_max_id
	[[ -z "$cur_max_id" ]] && continue
	[[ -z "$max_id" ]] && continue
	[[ $cur_max_id -ge $max_id ]] && continue
	cd $PWD
	for (( j=$cur_max_id ; j<=$max_id ; j++ )); do
		echo $j >> $banned_file
	done
	echo ids to check
	cat $banned_file
        rm -rf $tmpfile
        sleep 1
done
