#!/bin/bash

TOPIC_TYPE="$1" # group, subject

G_PWD=`pwd`
G_RET=""
G_TOPIC_TYPE_ARR=("group" "subject")

source $G_PWD/env.sh
source $G_PWD/util.sh

print_warning https_proxy : $https_proxy
print_warning E_SLEEP_PERIOD : $E_SLEEP_PERIOD


if [ ${#TOPIC_TYPE} -eq 0 ];
then
	print_error TOPIC TYPE LENGTH should not be zero!
	exit 1
fi


if [[ " ${G_TOPIC_TYPE_ARR[@]} " =~ " $TOPIC_TYPE " ]]
then
	: # NOP
else
	print_error $TOPIC_TYPE not in allow list: ${G_TOPIC_TYPE_ARR[@]}
	exit 1
fi


G_GIT_REPO_DIR=${E_BGM_ARCHIVE_GIT_REPO:-~/source/bgm-archive}
G_GROUP_TOPIC_AVOID_LIST=$E_BGM_GROUP_TOPIC_AVOID_LIST
G_SUBJECT_TOPIC_AVOID_LIST=$E_BGM_SUBJECT_TOPIC_AVOID_LIST
G_BLOG_AVOID_LIST=$E_BGM_BLOG_AVOID_LIST


BGM_RAUKEN_TOPICLIST_URL_TEMPLATE="https://%s/rakuen/topiclist?type=$TOPIC_TYPE"
BGM_GROUP_TOPIC_URL_TEMPLATE="https://%s/m/topic/$TOPIC_TYPE"
BGM_DOMAIN_LIST=$E_BGM_DOMAIN_LIST

TMP_BGM_RAUKEN_TOPICLIST_URL=
TMP_BGM_GROUP_TOPIC_URL=

SUCCESS_COUNTER=0
FAILURE_COUNTER=0
currentTimeMills
START_TIME=$G_RET

mkdir -p $G_GIT_REPO_DIR/$TOPIC_TYPE
cd $G_GIT_REPO_DIR
print_info PWD: `pwd`
print_info Initializing git repository
exec_cmd_nobail_naked "$G_GIT_CMD init"
print_info Pulling from remote
exec_cmd_nobail_naked "$G_GIT_CMD pull"
cd $G_PWD
print_info PWD: `pwd`

currentTimeMills
print_info Current Time Milliseconds: $G_RET
currentTimeISO
print_info Current Time ISO 8601: $G_RET

# Get NG list from file
declare -a ng_list
#cat $G_GIT_REPO_DIR/$TOPIC_TYPE/ng.txt | sort -u | uniq > $G_GIT_REPO_DIR/$TOPIC_TYPE/ng.txt
readarray -t ng_list < $G_GIT_REPO_DIR/$TOPIC_TYPE/ng.txt
> $G_GIT_REPO_DIR/$TOPIC_TYPE/ng.txt
print_success NG LIST ${ng_list[@]}

# Get topic list from rakuen
print_info Domain list ${BGM_DOMAIN_LIST[@]}
randBgmDomain
print_info Random Bangumi domain picked : $G_RET
printf -v TMP_BGM_RAUKEN_TOPICLIST_URL "$BGM_RAUKEN_TOPICLIST_URL_TEMPLATE" $G_RET
curlToFile $TMP_BGM_RAUKEN_TOPICLIST_URL $G_GIT_REPO_DIR/$TOPIC_TYPE/rakuen_topic_list.html
topic_list=(`grep -Po '(?<=href="/rakuen/topic/'$TOPIC_TYPE'/)[0-9]+' $G_GIT_REPO_DIR/$TOPIC_TYPE/rakuen_topic_list.html | sort | uniq`)
# Clear
> $G_GIT_REPO_DIR/$TOPIC_TYPE/topiclist.txt
# Write
for i in ${topic_list[@]}
do
	echo "$i" >> $G_GIT_REPO_DIR/$TOPIC_TYPE/topiclist.txt
done
print_success TOPIC LIST: ${topic_list[@]}


function archive() {
	arr=("$@")
	for i in ${arr[@]}
	do
		print_info archiving $TOPIC_TYPE topic $i
		if [[ " ${G_GROUP_TOPIC_AVOID_LIST[@]} " =~ " $i " ]]
			then
				print_warning $i is in AVOID LIST
		else
			ten_thousand=$(expr $i / 10000)
			printf -v ten_thousand "%02d" $ten_thousand
			hundred=$(expr $(expr $i % 10000) / 100)
			printf -v hundred "%02d" $hundred
			output_dir=$G_GIT_REPO_DIR/$TOPIC_TYPE/$ten_thousand/$hundred
			output_loc=$output_dir/$i.html
			mkdir -p $output_dir
			randBgmDomain
			printf -v TMP_BGM_GROUP_TOPIC_URL "$BGM_GROUP_TOPIC_URL_TEMPLATE" $G_RET
			printCurrentTimeISO
			print_info $TMP_BGM_GROUP_TOPIC_URL/$i to $output_loc
			curlToFile $TMP_BGM_GROUP_TOPIC_URL/$i $output_loc
			if [[ $G_RET -eq 0 ]]
			then
				trimHtml $output_loc
				tidyHtml $output_loc
				((SUCCESS_COUNTER++))
				print_success SUCCESS_COUNTER: $SUCCESS_COUNTER
			else
				print_error Archiving $TOPIC_TYPE id $i failed. Writing to ng.txt
				echo "$i" >> $G_GIT_REPO_DIR/$TOPIC_TYPE/ng.txt
				((FAILURE_COUNTER++))
				print_error FAILURE_COUNTER: $FAILURE_COUNTER
			fi
			sleep $E_SLEEP_PERIOD
		fi
		currentTimeMills
		tmp_timing=$G_RET
		print_info Timing: $(($tmp_timing - $START_TIME))ms
		print_info Avg: $((($tmp_timing - $START_TIME)/$(($SUCCESS_COUNTER + $FAILURE_COUNTER))))ms per archive
	done
}

archive ${ng_list[@]}
archive ${topic_list[@]}

cd $G_GIT_REPO_DIR
git_commit_msg="${TOPIC_TYPE^^} TOPIC: "
currentTimeISO
git_commit_msg+=" $G_RET "
currentTimeMills
git_commit_msg+="| $G_RET"
exec_cmd_nobail_naked "rm -rf $TOPIC_TYPE/rakuen_topic_list.html"
exec_cmd_nobail_naked "$G_GIT_CMD add $TOPIC_TYPE/*"
$G_GIT_CMD commit --allow-empty -m "$git_commit_msg"
exec_cmd_nobail_naked "$G_GIT_CMD push"
cd $G_PWD

print_info success
