#!/bin/bash

cookie_file=$PWD/bgm_tv_cookies.txt
ua="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/132.0.0.0 Safari/537.36 Edg/132.0.0.0"
removed_group_list_file=$PWD/removed_group_list_file.txt
banned_group_list_file=$PWD/banned_group_list_file.txt

for i in {1700..1701}; do

    echo iterating group $i
    tmp_file=`mktemp`
    curl -b $cookie_file -A "${ua}" --connect-timeout 10 --max-time 20 --retry 6 --retry-delay 3 --retry-max-time 60 -s -L "https://bgm.tv/group/$i" --output $tmp_file
    line_404_login=`grep "img/bangumi/404" $tmp_file`
    # echo $line_404_login
    len_login=${#line_404_login}

    curl -A "${ua}" --connect-timeout 10 --max-time 20 --retry 6 --retry-delay 3 --retry-max-time 60 -s -L "https://bgm.tv/group/$i" --output $tmp_file
    line_404_wo_cookie=`grep "img/bangumi/404" $tmp_file`
    # echo $line_404_wo_cookie
    len_wo_cookie=${#line_404_wo_cookie}

    if [[ $len_login -lt 3 ]] && [[ $len_wo_cookie -lt 3 ]]
    then
        echo $i is normal
    elif [[ $len_login -lt 3 ]] && [[ $len_wo_cookie -ge 3 ]]
    then
        echo $i is banned
        echo $i >> $banned_group_list_file
    elif [[ $len_login -ge 3 ]] && [[ $len_wo_cookie -ge 3 ]]
    then
        echo $i is removed
        echo $i >> $removed_group_list_file
    fi

    rm -rf $tmp_file

    sleep 1.2
done
