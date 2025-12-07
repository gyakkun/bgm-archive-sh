#!/bin/bash

source $G_PWD/env.sh
G_GIT_CMD=${E_GIT_CMD:-git}
G_CURL_CMD=${E_CURL_CMD:-curl}

# Start - Quote from nodesource_setup.sh

if test -t 1; then # if terminal
    ncolors=$(which tput > /dev/null && tput colors) # supports color
    if test -n "$ncolors" && test $ncolors -ge 8; then
        termcols=$(tput cols)
        bold="$(tput bold)"
        underline="$(tput smul)"
        standout="$(tput smso)"
        normal="$(tput sgr0)"
        black="$(tput setaf 0)"
        red="$(tput setaf 1)"
        green="$(tput setaf 2)"
        yellow="$(tput setaf 3)"
        blue="$(tput setaf 4)"
        magenta="$(tput setaf 5)"
        cyan="$(tput setaf 6)"
        white="$(tput setaf 7)"
    fi
fi

# bail： 报错退出?

bail() {
    print_error 'Error executing command, exiting'
    exit 1
}

exec_cmd_nobail() {
    print_normal "+ $1"
    bash -c "$1"
}

exec_cmd() {
    exec_cmd_nobail "$1" || bail
}

# End - Quote from nodesource_setup.sh

# "_naked" for executing the command in the current bash 
# environment, rather than using "bash -c "$1"". This can 
# avoid the problem that when executing module-related 
# commands with "exec_cmd", the new bash environtment will 
# "short circuit" the previous module operation because of
# the reset env-vars. (+ NAKED)

exec_cmd_nobail_naked() {
	print_normal "+ $1 + (NAKED)"
	$1
}

exec_cmd_naked() {
    exec_cmd_nobail_naked "$1" || bail
}

# "_nd" for "nodisplay", with this suffix the executed
# command wouldn't display the succesive lines other than
# the command it self in the first line. (+ NAKED_ND)

exec_cmd_naked_nobail_nd() {
	print_normal "+ $1 + (NAKED_ND)"
	$1 &> /dev/null
}

exec_cmd_naked_nd() {
	exec_cmd_naked_nobail_nd "$1" || bail
}

print_normal() {
	echo "${normal}$@${normal}"
}

print_info() {
	echo "${cyan}[Info] $@${normal}"
}

print_warning() {
	echo "${yellow}[Warning] $@${normal}"
}

print_error() {
	echo "${red}${bold}[Error]${normal} ${red}$@${normal}"
}

print_success() {
	echo "${green}[Success] $@${normal}"
}

##########################################################################


command_exists() {
  command -v "$1" >/dev/null 2>&1
}

curlToFile() {
	curl_temp_file=`mktemp`
	curl_cookie_file=${E_BGM_COOKIE_FILE:-/dev/null}
	curl_ua=${E_BGM_UA:-"curl"}
	curl_command_this_time=''$G_CURL_CMD' -w %{http_code} --connect-timeout 10 '
	curl_command_this_time+=' -b '$curl_cookie_file' '
	curl_command_this_time+=' -A "'"${curl_ua}"'" '
	curl_command_this_time+=' --max-time 20 '
	curl_command_this_time+=' --retry 6 '
	curl_command_this_time+=' --retry-delay 3 '
	curl_command_this_time+=' --retry-max-time 60 '
	curl_command_this_time+=' -s -L --output '$curl_temp_file' '$1' '
	print_info Going to execute $curl_command_this_time
	curl_http_code=`$G_CURL_CMD -w %{http_code} --connect-timeout 10 -b $curl_cookie_file -A "${curl_ua}" --max-time 20 --retry 6 --retry-delay 3 --retry-max-time 60 -s -L --output $curl_temp_file $1`
	if [[ $((curl_http_code)) -eq 200 ]]
	then
		: # NOP
	else
		print_error CODE $curl_http_code
		G_RET=1
		rm $curl_temp_file
		return
	fi
	curl_temp_file_as_string=`cat $curl_temp_file`
	curl_temp_file_length=${#curl_temp_file_as_string}
	if [[ $curl_temp_file_length -lt 3 ]]
	then
		print_error curl failed: Zero length result - $1 
		G_RET=1
	else
		cat $curl_temp_file > $2
		G_RET=0
	fi
	rm $curl_temp_file
}

trimHtmlBefore() {
        OLD_USER=$(sed -nE 's/.*href="\/book\/list\/([^/"]+).*/\1/p' $1 | head -1)
	if [[ -z "$OLD_USER" ]]; then
	    OLD_USER="bgmarchive"
	fi
	NEW_USER=gyakkun
        NEW_UID=304116
        NEW_NAME='304116'
	FORMHASH=$(sed -nE 's|.*href="https://bgm.tv/logout/([^"]+)".*|\1|p' $1 | head -1)
	# dd if=/dev/urandom bs=4 count=1 2>/dev/null | xxd -p
	FORMPLACEHOLDER=7f76f8a2

	#echo old user $OLD_USER
	#echo new user $NEW_USER
	#echo command "s|(href=\"[^\"]*/?)${OLD_USER}([/\"\?]|$)|\1${NEW_USER}\2|g"

	#echo debug1
        sed -i -E \
          -e "s|(CHOBITS_UID\s*=\s*)[0-9]+|\1$NEW_UID|" \
          -e "s|(CHOBITS_USERNAME\s*=\s*)'[^']*'|\1'$NEW_NAME'|" \
          $1
	sed -i -E "s#${FORMHASH}#${FORMPLACEHOLDER}#g" $1
	#echo debug2
	# href should be replaced by uid since gyakkun has no username
	sed -i -E "s#(href=\"[^\"]*/?)${OLD_USER}([/\"\?]|$)#\1${NEW_UID}\2#g" $1
	#echo debug3
	sed -i -E -e "s#>([[:space:]]*)${OLD_USER}([[:space:]]*)<#>\1${NEW_USER}\2<#g" $1
        sed -i 's|<script.*</script>||g' $1
        sed -i 's|^[ \t]*||g' $1
        sed -i '/^$/d' $1
	sed -i 's|<input\s\+type="hidden"\s\+name="lastview"\s\+value="[0-9]\+"\s*/>|<input name="lastview" type="hidden" value="0" />|g' $1
}

trimHtmlAfter() {
	sed -i 's|<div\s\+class="speech"\s\+id="robot_speech"\s\+style="display:none;">.*</div>|<div class="speech" id="robot_speech" style="display:none;">Hi there, here is bgm-archive.</div>|g' $1
	sed -i 's|bg musume_[0-9]\+|bg musume_1|g' $1
	sed -i 's|id="robot"|id="robot" hidden|g' $1
	sed -i 's|^(window.NREUM.*$||g' $1
	sed -i 's|^.*NRBA=o})();||g' $1
        sed -i '/^$/d' $1
}

tidyHtml() {
	if command_exists tidy; then
		print_info tidying $i
		exec_cmd_nobail_naked "tidy --drop-empty-elements no \
--hide-comments yes \
--tidy-mark no \
--wrap 0 \
--sort-attributes alpha \
--quiet yes \
--show-warnings no \
-o $1 $1"
	fi
}

randBgmDomain() {
	G_RET=${BGM_DOMAIN_LIST["$[RANDOM % ${#BGM_DOMAIN_LIST[@]}]"]};
}

currentTimeMills() {
	G_RET=$(($(date +%s%N)/1000000))
}

currentTimeISO() {
	G_RET=$(date -u +'%Y-%m-%dT%H:%M:%S.%3NZ')
}

printCurrentTimeISO() {
	echo $(date -u +'%Y-%m-%dT%H:%M:%S.%3NZ')
}

getBaMetaTs() {
	meta_comment="<!-- ba-meta-ts:"
	currentTimeMills
	meta_comment+="${G_RET}"
	meta_comment+=" -->"
	G_RET=$meta_comment
}

getBaMetaTsForFile() {
	local topic_id=$1
	meta_ts="${topic_id}:"
	currentTimeMills
	meta_ts+="${G_RET}"
	G_RET=$meta_ts
}

nextSleep() {
	currentTimeMills
	local current_time_ms=$G_RET
	local start_time_ms=$1
	start_time_ms=$(($start_time_ms < $current_time_ms ? $start_time_ms : $current_time_ms))
	local current_idx_count_from_one=$2
	current_idx_count_from_one=$(($current_idx_count_from_one >= 1 ? $current_idx_count_from_one : 1))
	local total_count=$3
	total_count=$(($total_count >= 1 ? $total_count : 1))
	local target_time_sec_each_round=$4
	local target_time_ms_each_round=$(awk "BEGIN {printf \"%d\",${target_time_sec_each_round}*1000}")
	target_time_ms_each_round=$(($target_time_ms_each_round >= 512 ? $target_time_ms_each_round : 512))
	
	local elapsed_time_ms=$(($current_time_ms - $start_time_ms))
	elapsed_time_ms=$(($elapsed_time_ms >= 0 ? $elapsed_time_ms : 0))
	local avg_ms_each=$(($elapsed_time_ms / $current_idx_count_from_one))
	local remain_ms=$(($target_time_ms_each_round * $total_count - $elapsed_time_ms)) # could be negative, guarded by the 200ms bound
	local remain_rounds=$(($total_count - $current_idx_count_from_one))
	remain_rounds=$(($remain_rounds >= 1 ? $remain_rounds : 1))
	local next_sleep_ms=$(($remain_ms / ($total_count - $current_idx_count_from_one)))
	next_sleep_ms=$(($next_sleep_ms >= 512 ? $next_sleep_ms : 512))
	# print_warning star_time_ms $start_time_ms
	# print_warning current_time_ms $current_time_ms
	# print_warning current_idx_count_from_one $current_idx_count_from_one
	# print_warning total_count $total_count
	# print_warning target_time_sec_each_round $target_time_sec_each_round
	# print_warning target_time_ms_each_round $target_time_ms_each_round
	# print_warning elapsed_time_ms $elapsed_time_ms
	# print_warning avg_ms_each $avg_ms_each
	# print_warning remain_ms $remain_ms
	# print_warning next_sleep_ms $next_sleep_ms
	G_RET=$(awk "BEGIN {printf \"%.2f\",${next_sleep_ms}/1000}")
}
