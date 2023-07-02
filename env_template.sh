#!/bin/bash

export http_proxy=${http_proxy}
export https_proxy=${https_proxy}

export E_BGM_ARCHIVE_GIT_REPO=
export E_BGM_ARCHIVE_JSON_GIT_REPO=
export E_BGM_COOKIE_FILE=
touch $E_BGM_COOKIE_FILE
export E_BGM_UA=
# Please export as : $ export E_BGM_DOMAIN_LIST="chii.in bangumi.tv"
export E_BGM_DOMAIN_LIST=(${E_BGM_DOMAIN_LIST:-"bgm.tv"})
#echo "${E_BGM_DOMAIN_LIST[@]}"
#export E_BGM_DOMAIN_LIST=(bangumi.tv bgm.tv chii.in)

export E_GIT_CMD="git "
export E_CURL_CMD="curl "

export E_SLEEP_PERIOD=${E_SLEEP_PERIOD:-1}

export E_WEBHOOK_CMD="echo WEBHOOK STUB"

export E_BGM_TEST_CMD="curl -sL -b $E_BGM_COOKIE_FILE -A \"${E_BGM_UA}\" https://bgm.tv/m"
