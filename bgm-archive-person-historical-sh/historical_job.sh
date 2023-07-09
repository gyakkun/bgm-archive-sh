#!/bin/bash

TOPIC_TYPE=person
MAX_ID=55800
SLEEP_PERIOD=2
BGM_DOMAIN="bgm.tv"
G_GIT_REPO_DIR=${BGM_GIT_REPO:-~/source/bgm-archive-${TOPIC_TYPE}-historical}
G_PWD=`pwd`
G_RET=""

#export http_proxy=
#export https_proxy=

source $G_PWD/util.sh

BGM_UA='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36 Edg/115.0.1901.157'
BGM_COOKIE_FILE="$G_PWD/bgm_cookies.txt"
echo G_GIT_REPO_DIR $G_GIT_REPO_DIR

last_topic_id=`cat $G_GIT_REPO_DIR/last_${TOPIC_TYPE}_id`
echo $last_topic_id
cd $G_GIT_REPO_DIR
#git pull -f
cd $G_PWD

for (( i=$(expr $last_topic_id + 1);i<=$MAX_ID;i++ ))
#for (( i=1;i<=1210000;i++ ))
do
        echo archiving $i
        ten_thousand=$(expr $i / 10000)
        printf -v ten_thousand "%02d" $ten_thousand
        hundred=$(expr $(expr $i % 10000) / 100)
        printf -v hundred "%02d" $hundred
        output_dir=$G_GIT_REPO_DIR/$TOPIC_TYPE/$ten_thousand/$hundred
        output_loc=$output_dir/$i.html
        mkdir -p $output_dir
	# CURL TO FILE
        curl -sL -b $BGM_COOKIE_FILE -A "$BGM_UA" --connect-timeout 10 --max-time 20 --retry 6 \
		      --retry-delay 3 --retry-max-time 60 --output $output_loc "https://$BGM_DOMAIN/$TOPIC_TYPE/$i"
        # CLEAN BEFORE TIDY
	sed -i 's|<script.*</script>||g' $output_loc
        sed -i 's|^[ \t]*||g' $output_loc
        sed -i '/^$/d' $output_loc
        sed -i 's|<input\s\+type="hidden"\s\+name="lastview"\s\+value="[0-9]\+"\s*/>|<input name="lastview" type="hidden" value="0" />|g' $output_loc
        # TIDY
	if command_exists tidy; then
	        echo tidying $i
                tidy    --drop-empty-elements no \
			--hide-comments yes \
                        --tidy-mark no \
                        --wrap 0 \
                        --sort-attributes alpha \
                        --quiet yes \
                        --show-warnings no \
                        -m $output_loc
        fi
	# CLEAN AFTER TIDY
        sed -i 's|<div\s\+class="speech"\s\+id="robot_speech"\s\+style="display:none;">.*</div>|<div class="speech" id="robot_speech" style="display:none;">Hi there, here is bgm-archive.</div>|g' $output_loc
        sed -i 's|bg musume_[0-9]\+|bg musume_1|g' $output_loc
        sed -i 's|id="robot"|id="robot" hidden|g' $output_loc
        sed -i 's|^(window.NREUM.*$||g' $output_loc
        sed -i 's|^.*NRBA=o})();||g' $output_loc
        sed -i '/^$/d' $output_loc

	# Write last id
        echo -n $i > last_${TOPIC_TYPE}_id

	# GIT COMMIT IT
        if [ $(expr $i % 1000) -eq 999 ]; then
                date
                cd $G_GIT_REPO_DIR
                echo -n $i > last_${TOPIC_TYPE}_id
                git_commit_msg="${TOPIC_TYPE^^} HISTORICAL: LAST ID $i"
                currentTimeISO
                git_commit_msg+=" | $G_RET"
                currentTimeMills
                git_commit_msg+=" | $G_RET"
                git add last_${TOPIC_TYPE}_id
                git add ${TOPIC_TYPE}/*
                git commit --allow-empty -m "$git_commit_msg"
                # git push
                cd $G_PWD
        fi
        sleep $SLEEP_PERIOD
done
