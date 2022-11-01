#!/bin/bash

export http_proxy=192.168.3.15:1183
export https_proxy=192.168.3.15:1183

export E_BGM_ARCHIVE_GIT_REPO=
export E_BGM_GROUP_TOPIC_AVOID_LIST=()
export E_BGM_SUBJECT_TOPIC_AVOID_LIST=()
export E_BGM_BLOG_AVOID_LIST=()
export E_BGM_DOMAIN_LIST=(bgm.tv)
#export E_BGM_DOMAIN_LIST=(bangumi.tv bgm.tv chii.in)

export E_GIT_CMD="proxychains git "
export E_CURL_CMD="curl "