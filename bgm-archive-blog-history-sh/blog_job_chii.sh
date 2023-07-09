#!/bin/bash

G_GIT_REPO_DIR=${BGM_GIT_REPO:-~/source/bgm-archive-blog-3}
G_GROUP_TOPIC_AVOID_LIST=()
G_PWD=`pwd`
G_RET=""

source $G_PWD/util.sh

export http_proxy=192.168.3.3:1183
export https_proxy=192.168.3.3:1183
export BGM_UA='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36 Edg/112.0.1722.15'
export BGM_COOKIE_FILE="$G_PWD/bgm_cookies.txt"

last_blog_id=`cat $G_GIT_REPO_DIR/last_blog_id`
cd $G_GIT_REPO_DIR
# proxychains git pull -f
cd $G_PWD

#for (( i=$(expr $last_blog_id + 1);i<=321000;i++ ))
for (( i=270917;i<=271213;i++ ))
do
	echo archiving $i
	ten_thousand=$(expr $i / 10000)
	printf -v ten_thousand "%02d" $ten_thousand
	hundred=$(expr $(expr $i % 10000) / 100)
	printf -v hundred "%02d" $hundred
	output_dir=$G_GIT_REPO_DIR/blog/$ten_thousand/$hundred
	output_loc=$output_dir/$i.html
	mkdir -p $output_dir
	curl -sL -b $BGM_COOKIE_FILE -A "$BGM_UA" --connect-timeout 10 --max-time 20 --retry 6 --retry-delay 3 --retry-max-time 60 --output $output_loc "https://chii.in/blog/$i"
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
		date
		cd $G_GIT_REPO_DIR
		echo -n $i > last_blog_id
		git_commit_msg="BLOG HISTORICAL: LAST ID $i"
		currentTimeISO
		git_commit_msg+="| $G_RET "
		currentTimeMills
		git_commit_msg+="| $G_RET"
		git add last_blog_id
		git add blog/*
		git commit --allow-empty -m "$git_commit_msg"
		# proxychains git push
		cd $G_PWD
	fi
	sleep 1.5
done
