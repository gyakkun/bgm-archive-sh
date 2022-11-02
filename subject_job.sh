#!/bin/bash

G_PWD=`pwd`
G_RET=""

source $G_PWD/env.sh
source $G_PWD/util.sh

G_GIT_REPO_DIR=${E_BGM_ARCHIVE_GIT_REPO:-~/source/bgm-archive}
G_GROUP_TOPIC_AVOID_LIST=$E_BGM_GROUP_TOPIC_AVOID_LIST
G_SUBJECT_TOPIC_AVOID_LIST=$E_BGM_SUBJECT_TOPIC_AVOID_LIST
G_BLOG_AVOID_LIST=$E_BGM_BLOG_AVOID_LIST


BGM_RAUKEN_TOPICLIST_URL_TEMPLATE="https://%s/rakuen/topiclist?type=subject"
BGM_SUBJECT_TOPIC_URL_TEMPLATE="https://%s/m/topic/subject"
BGM_DOMAIN_LIST=(chii.in)

TMP_BGM_RAUKEN_TOPICLIST_URL=
TMP_BGM_SUBJECT_TOPIC_URL=


mkdir -p $G_GIT_REPO_DIR/subject
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

echo domain list $BGM_DOMAIN_LIST
randBgmDomain
print_info Random Bangumi domain picked : $G_RET
printf -v TMP_BGM_RAUKEN_TOPICLIST_URL "$BGM_RAUKEN_TOPICLIST_URL_TEMPLATE" $G_RET
#print_info after format $TMP_BGM_RAUKEN_TOPICLIST_URL $G_GIT_REPO_DIR/rakuen_topic_list.html
curlToFile $TMP_BGM_RAUKEN_TOPICLIST_URL $G_GIT_REPO_DIR/subject/rakuen_topic_list.html

topic_list=`grep -Po '(?<=href="/rakuen/topic/subject/)[0-9]+' $G_GIT_REPO_DIR/subject/rakuen_topic_list.html | sort | uniq`
#Clear
> $G_GIT_REPO_DIR/subject/topiclist.txt
for i in $topic_list
do
	echo "$i" >> $G_GIT_REPO_DIR/subject/topiclist.txt
done
topic_list=`grep -Po '(?<=href="/rakuen/topic/subject/)[0-9]+' $G_GIT_REPO_DIR/subject/rakuen_topic_list.html | sort | uniq | shuf`
print_info TOPIC LIST: $topic_list

for i in $topic_list
do
	print_info archiving subject topic $i
	if [[ " ${G_GROUP_TOPIC_AVOID_LIST[@]} " =~ " $i " ]]
		then
			print_warning $i is in AVOID LIST
	else
		ten_thousand=$(expr $i / 10000)
		printf -v ten_thousand "%02d" $ten_thousand
		hundred=$(expr $(expr $i % 10000) / 100)
		printf -v hundred "%02d" $hundred
		output_dir=$G_GIT_REPO_DIR/subject/$ten_thousand/$hundred
		output_loc=$output_dir/$i.html
		mkdir -p $output_dir
		randBgmDomain
		printf -v TMP_BGM_SUBJECT_TOPIC_URL "$BGM_SUBJECT_TOPIC_URL_TEMPLATE" $G_RET
		print_info $TMP_BGM_SUBJECT_TOPIC_URL/$i to $output_loc
		curlToFile $TMP_BGM_SUBJECT_TOPIC_URL/$i $output_loc
		trimHtml $output_loc
		tidyHtml $output_loc
		sleep 1
	fi
done

cd $G_GIT_REPO_DIR
git_commit_msg="SUBJECT TOPIC: "
currentTimeISO
git_commit_msg+=" $G_RET "
currentTimeMills
git_commit_msg+="| $G_RET"
exec_cmd_nobail_naked "rm -rf subject/rakuen_topic_list.html"
exec_cmd_nobail_naked "$G_GIT_CMD add subject/*"
$G_GIT_CMD commit --allow-empty -m "$git_commit_msg"
exec_cmd_nobail_naked "$G_GIT_CMD push"
cd $G_PWD

print_info success
