#!/bin/bash

export E_SLEEP_PERIOD=${E_SLEEP_PERIOD:-2.06}
export E_REST_SEC=${E_REST_SEC:-39}

export http_proxy=${http_proxy}
export https_proxy=${https_proxy}

export E_BGM_ARCHIVE_GIT_REPO=
export E_BGM_ARCHIVE_JSON_GIT_REPO=-
export E_BGM_GROUP_TOPIC_AVOID_LIST=() # in used?
export E_BGM_SUBJECT_TOPIC_AVOID_LIST=()
export E_BGM_BLOG_AVOID_LIST=()
export E_BGM_COOKIE_FILE=
touch $E_BGM_COOKIE_FILE
export E_BGM_UA='Mozilla/5.0 etc.'
# Please export as : $ export E_BGM_DOMAIN_LIST="chii.in bangumi.tv"
export E_BGM_DOMAIN_LIST=(${E_BGM_DOMAIN_LIST:-"bgm.tv"})
#echo "${E_BGM_DOMAIN_LIST[@]}"
#export E_BGM_DOMAIN_LIST=(bangumi.tv bgm.tv chii.in)

export E_GIT_CMD="git "
export E_CURL_CMD="curl "

export E_WEBHOOK_CMD="date ; cd ${JSON_REPO}; curl http://127.0.0.1:5926/hook/commit?id=${HTML_REPO_ID}  ;  bash ${CHECK_BANNED_GROUP_SCRIPT} ; bash ${MAX_CPE_SCRIPT} "

# legacy bgm-archive-kt config
export E_BGM_ARCHIVE_IS_REMOVE_JSON_AFTER_PROCESS=true
export E_BGM_ARCHIVE_PORT=23456
export E_BGM_ARCHIVE_HOW_MANY_COMMIT_ON_GITHUB_PER_DAY=1000
export E_BGM_ARCHIVE_DISABLE_DB_PERSIST_KEY=true
