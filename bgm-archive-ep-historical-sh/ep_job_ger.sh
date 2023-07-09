#!/bin/bash

G_GIT_REPO_DIR=${BGM_GIT_REPO:-~/source/bgm-archive-ep-historical}
G_GROUP_TOPIC_AVOID_LIST=()
G_PWD=`pwd`
G_RET=""

source $G_PWD/util.sh

#export http_proxy=192.168.3.3:1183
#export https_proxy=192.168.3.3:1183
export BGM_UA='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36 Edg/114.0.1823.18'
export BGM_COOKIE_FILE="$G_PWD/bgm_cookies.txt"

last_ep_id=`cat $G_GIT_REPO_DIR/last_ep_id`
cd $G_GIT_REPO_DIR
# proxychains git pull -f
cd $G_PWD

#for (( i=$(expr $last_ep_id + 1);i<=213200;i++ ))
for (( i=1;i<=1210000;i++ ))
do
        echo archiving $i
        ten_thousand=$(expr $i / 10000)
        printf -v ten_thousand "%02d" $ten_thousand
        hundred=$(expr $(expr $i % 10000) / 100)
        printf -v hundred "%02d" $hundred
        output_dir=$G_GIT_REPO_DIR/ep/$ten_thousand/$hundred
        output_loc=$output_dir/$i.html
        mkdir -p $output_dir
        curl -sL -b $BGM_COOKIE_FILE -A "$BGM_UA" --connect-timeout 10 --max-time 20 --retry 6 --retry-delay 3 --retry-max-time 60 --output $output_loc "https://bgm.tv/ep/$i"
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
        if [ $(expr $i % 1000) -eq 999 ]; then
                date
                cd $G_GIT_REPO_DIR
                echo -n $i > last_ep_id
                git_commit_msg="EP HISTORICAL: LAST ID $i"
                currentTimeISO
                git_commit_msg+="| $G_RET "
                currentTimeMills
                git_commit_msg+="| $G_RET"
                git add last_ep_id
                git add blog/*
                git commit --allow-empty -m "$git_commit_msg"
                # proxychains git push
                cd $G_PWD
        fi
        sleep 2.8
done