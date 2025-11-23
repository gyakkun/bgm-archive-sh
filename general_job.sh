#!/bin/bash

TOPIC_TYPE="$1" # group, subject

G_PWD=`pwd`
G_RET=""
G_TOPIC_TYPE_ARR=("group" "subject" "blog" "ep" "person" "character")
G_BEPC_TYPE_ARR=("blog" "ep" "person" "character")
G_MONO_TYPE_ARR=("person" "character")

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
BGM_MONO_TOPICLIST_URL_TEMPLATE="https://%s/rakuen/topiclist?type=mono&$TOPIC_TYPE"
BGM_TOPIC_URL_TEMPLATE="https://%s/m/topic/$TOPIC_TYPE"
BGM_BEPC_URL_TEMPLATE="https://%s/$TOPIC_TYPE"
BGM_DOMAIN_LIST=$E_BGM_DOMAIN_LIST

TMP_BGM_RAUKEN_TOPICLIST_URL=
TMP_BGM_TOPIC_URL=
TMP_BGM_BLOG_URL=

SUCCESS_COUNTER=0
FAILURE_COUNTER=0
currentTimeMills
START_TIME=$G_RET
DURING_NG=0

META_TS_FILE=$G_GIT_REPO_DIR/$TOPIC_TYPE/meta_ts.txt
>$META_TS_FILE

mkdir -p $G_GIT_REPO_DIR/$TOPIC_TYPE
cd $G_GIT_REPO_DIR
print_info PWD: `pwd`
print_info Initializing git repository
# exec_cmd_nobail_naked "$G_GIT_CMD init"
print_info Pulling from remote
# exec_cmd_nobail_naked "$G_GIT_CMD pull"
cd $G_PWD
print_info PWD: `pwd`

currentTimeMills
print_info Current Time Milliseconds: $G_RET
currentTimeISO
print_info Current Time ISO 8601: $G_RET

# Get NG list from file
declare -a ng_list
touch $G_GIT_REPO_DIR/$TOPIC_TYPE/ng.txt
ng_list=(`cat $G_GIT_REPO_DIR/$TOPIC_TYPE/ng.txt | sort -u | uniq`) # > $G_GIT_REPO_DIR/$TOPIC_TYPE/ng.txt
#readarray -t ng_list < $G_GIT_REPO_DIR/$TOPIC_TYPE/ng.txt
#> $G_GIT_REPO_DIR/$TOPIC_TYPE/ng.txt
print_success NG LIST ${ng_list[@]}


# Get Spot Check list from file
declare -a sc_list
touch $G_GIT_REPO_DIR/$TOPIC_TYPE/sc.txt
sc_list=(`cat $G_GIT_REPO_DIR/$TOPIC_TYPE/sc.txt | sort -u | uniq`) # > $G_GIT_REPO_DIR/$TOPIC_TYPE/sc.txt
#readarray -t sc_list < $G_GIT_REPO_DIR/$TOPIC_TYPE/sc.txt
#> $G_GIT_REPO_DIR/$TOPIC_TYPE/sc.txt
print_success SPOT CHECK LIST ${sc_list[@]}


# Get Spot Check list from file
declare -a bn_list
touch $G_GIT_REPO_DIR/$TOPIC_TYPE/bn.txt
bn_list=(`cat $G_GIT_REPO_DIR/$TOPIC_TYPE/bn.txt | sort -u | uniq`) # > $G_GIT_REPO_DIR/$TOPIC_TYPE/sc.txt
#readarray -t sc_list < $G_GIT_REPO_DIR/$TOPIC_TYPE/sc.txt
#> $G_GIT_REPO_DIR/$TOPIC_TYPE/bn.txt
print_success BANNED GROUP LIST ${bn_list[@]}


# Get topic list from rakuen
print_info Domain list ${BGM_DOMAIN_LIST[@]}
randBgmDomain
bgm_domain_picked=$G_RET
print_info Random Bangumi domain picked : $bgm_domain_picked
printf -v TMP_BGM_RAUKEN_TOPICLIST_URL "$BGM_RAUKEN_TOPICLIST_URL_TEMPLATE" $bgm_domain_picked
if [[ " ${G_MONO_TYPE_ARR[@]} " =~ " $TOPIC_TYPE " ]];then
	printf -v TMP_BGM_RAUKEN_TOPICLIST_URL "$BGM_MONO_TOPICLIST_URL_TEMPLATE" $bgm_domain_picked
fi
curlToFile $TMP_BGM_RAUKEN_TOPICLIST_URL $G_GIT_REPO_DIR/$TOPIC_TYPE/rakuen_topic_list.html


# Blog
if [ "$TOPIC_TYPE" == "blog" ]; then
	topic_list=(`grep -aPo '(?<=href="/blog/)[0-9]+' $G_GIT_REPO_DIR/$TOPIC_TYPE/rakuen_topic_list.html | uniq`)
# Person
elif [ "$TOPIC_TYPE" == "person" ]; then
	topic_list=(`grep -aPo '(?<=href="/rakuen/topic/prsn/)[0-9]+' $G_GIT_REPO_DIR/$TOPIC_TYPE/rakuen_topic_list.html | uniq`)
# Character
elif [ "$TOPIC_TYPE" == "character" ]; then
	topic_list=(`grep -aPo '(?<=href="/rakuen/topic/crt/)[0-9]+' $G_GIT_REPO_DIR/$TOPIC_TYPE/rakuen_topic_list.html | uniq`)
# Episode
elif [ "$TOPIC_TYPE" == "ep" ]; then
	topic_list=(`grep -aPo '(?<=href="/rakuen/topic/ep/)[0-9]+' $G_GIT_REPO_DIR/$TOPIC_TYPE/rakuen_topic_list.html |  uniq | head -n 50`)
# Group / Subject Topic
else
	#topic_list=(`grep -aPo '(?<=href="/rakuen/topic/'$TOPIC_TYPE'/)[0-9]+' $G_GIT_REPO_DIR/$TOPIC_TYPE/rakuen_topic_list.html | sort -rn | uniq`)
	topic_list=(`grep -aPo '(?<=href="/rakuen/topic/'$TOPIC_TYPE'/)[0-9]+' $G_GIT_REPO_DIR/$TOPIC_TYPE/rakuen_topic_list.html | uniq | head -n 50 `)
fi

# Clear
> $G_GIT_REPO_DIR/$TOPIC_TYPE/topiclist.txt
# Write
for i in ${topic_list[@]}
do
	echo "$i" >> $G_GIT_REPO_DIR/$TOPIC_TYPE/topiclist.txt
done
print_success ${TOPIC_TYPE^^} LIST: ${topic_list[@]}
# Shuffle the topic list
# topic_list=(`shuf -e ${topic_list[@]}`)


function archive() {
	arr=("$@")
	for i in ${arr[@]}
	do
		ten_thousand=$(expr $i / 10000)
		printf -v ten_thousand "%02d" $ten_thousand
		hundred=$(expr $(expr $i % 10000) / 100)
		printf -v hundred "%02d" $hundred
		output_dir=$G_GIT_REPO_DIR/$TOPIC_TYPE/$ten_thousand/$hundred
		output_loc=$output_dir/$i.html
		mkdir -p $output_dir
		randBgmDomain
		printf -v TMP_BGM_TOPIC_URL "$BGM_TOPIC_URL_TEMPLATE" $G_RET
		if [[ " ${G_BEPC_TYPE_ARR[@]} " =~ " $TOPIC_TYPE " ]];then
			printf -v TMP_BGM_TOPIC_URL "$BGM_BEPC_URL_TEMPLATE" $G_RET
		fi
		printCurrentTimeISO
		print_info $TMP_BGM_TOPIC_URL/$i to $output_loc
		curlToFile $TMP_BGM_TOPIC_URL/$i $output_loc
		if [[ $G_RET -eq 0 ]]
		then
			trimHtmlBefore $output_loc
			[[ $DURING_NG -eq 0 ]] && tidyHtml $output_loc
			trimHtmlAfter $output_loc
			getBaMetaTsForFile $i
			echo "${G_RET}" >> $META_TS_FILE
			# getBaMetaTs
			# echo "${G_RET}" >> $output_loc
			((SUCCESS_COUNTER++))
			print_success SUCCESS_COUNTER: $SUCCESS_COUNTER
		else
			print_error Archiving $TOPIC_TYPE id $i failed. Writing to ng.txt
			echo "$i" >> $G_GIT_REPO_DIR/$TOPIC_TYPE/ng.txt
			((FAILURE_COUNTER++))
			print_error FAILURE_COUNTER: $FAILURE_COUNTER
		fi
		sleep $E_SLEEP_PERIOD
		currentTimeMills
		tmp_timing=$G_RET
		print_info Timing: $(($tmp_timing - $START_TIME))ms
		print_info Avg: $((($tmp_timing - $START_TIME)/$(($SUCCESS_COUNTER + $FAILURE_COUNTER))))ms per archive
	done
}

archive ${topic_list[@]}
DURING_NG=1
archive ${ng_list[@]}
DURING_NG=0
archive ${sc_list[@]}
archive ${bn_list[@]}

cd $G_GIT_REPO_DIR

git_lock_counter=0

while [ -e $G_GIT_REPO_DIR/.git/index.lock ] && [ $((git_lock_counter)) -lt 72 ]
do
	print_warning Git is locked, waiting
	((git_lock_counter++))
	print_warning Git lock counter: $git_lock_counter
	sleep 5
done

if [ $((git_lock_counter)) -ge 72 ]
then
	print_error Git lock counter over maximum value 72: $git_lock_counter
	print_error Going to remove .git/index.lock forcibly.
	exec_cmd_nobail_naked "rm -rf $G_GIT_REPO_DIR/.git/index.lock"
fi

git_commit_msg="${TOPIC_TYPE^^} TOPIC: "
currentTimeISO
git_commit_msg+=" $G_RET "
currentTimeMills
git_commit_msg+="| $G_RET"
exec_cmd_nobail_naked "rm -rf $TOPIC_TYPE/rakuen_topic_list.html"

currentTimeISO
print_warning "About to git add $G_RET"
find $G_GIT_REPO_DIR/$TOPIC_TYPE/  -type f | tr '\n' ' ' | xargs git add
currentTimeISO
print_warning "Finish git add $G_RET"


currentTimeISO
print_warning "About to git commit $G_RET"
git commit --quiet --allow-empty -m "$git_commit_msg"
currentTimeISO
print_warning "Finish git commit $G_RET"

# exec_cmd_nobail_naked "$G_GIT_CMD push"
files_to_remove=`find $G_GIT_REPO_DIR/$TOPIC_TYPE/ -mindepth 1 -type d | tr '\n' ' '`
print_warning "Removing files $files_to_remove"
exec_cmd_nobail_naked "rm -rf $files_to_remove"
cd $G_PWD
> $G_GIT_REPO_DIR/$TOPIC_TYPE/ng.txt
> $G_GIT_REPO_DIR/$TOPIC_TYPE/sc.txt
> $G_GIT_REPO_DIR/$TOPIC_TYPE/bn.txt
exec_cmd_nobail "$E_WEBHOOK_CMD"

print_info success
