#!/bin/bash

G_GIT_REPO_DIR=${BGM_GIT_REPO:-~/source/bgm-archive}
G_GROUP_TOPIC_AVOID_LIST=()
G_PWD=`pwd`
G_RET=""

source $G_PWD/util.sh

export http_proxy=192.168.3.15:1183
export https_proxy=192.168.3.15:1183

last_group_topic_id=`cat $G_GIT_REPO_DIR/last_group_topic_id`
cd $G_GIT_REPO_DIR
proxychains git pull -f
cd $G_PWD

for (( i=$last_group_topic_id;i<=390000;i++ ))
do
	echo archiving $i
	ten_thousand=$(expr $i / 10000)
	printf -v ten_thousand "%02d" $ten_thousand
	hundred=$(expr $(expr $i % 10000) / 100)
	printf -v hundred "%02d" $hundred
	output_dir=$G_GIT_REPO_DIR/group/$ten_thousand/$hundred
	output_loc=$output_dir/$i.html
	mkdir -p $output_dir
	curl -sL --output $output_loc "http://mirror.bgm.rincat.ch/m/topic/group/$i"
        sed -i 's|<script.*</script>||g' $output_loc
        sed -i 's|^[ \t]*||g' $output_loc
        sed -i '/^$/d' $output_loc
	if command_exists tidy; then
		echo tidying $i
                tidy    --drop-empty-elements no \
                        --tidy-mark no \
                        --wrap 0 \
                        --sort-attributes alpha \
                        --quiet yes \
                        --show-warnings no \
                        -m $output_loc
        fi
	if [ $(expr $i % 100) -eq 99 ]; then
		cd $G_GIT_REPO_DIR
		echo -n $i > last_group_topic_id
		git_commit_msg="GROUP TOPIC HISTORICAL: LAST ID $i"
		currentTimeISO
		git_commit_msg+="| $G_RET "
		currentTimeMills
		git_commit_msg+="| $G_RET"
		git add *
		git commit --allow-empty -m "$git_commit_msg"
		proxychains git push
		cd $G_PWD
	fi
	sleep 1
done
