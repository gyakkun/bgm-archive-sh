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
	exec_cmd_nobail_naked "$G_CURL_CMD	--connect-timeout 10 \
--max-time 10 \
--retry 6 \
--retry-delay 3 \
--retry-max-time 40 \
-s -L --output $2 $1"
}

trimHtml() {
        sed -i 's|<script.*</script>||g' $1
        sed -i 's|^[ \t]*||g' $1
        sed -i '/^$/d' $1
}

tidyHtml() {
	if command_exists tidy; then
		print_info tidying $i
		exec_cmd_nobail_naked "tidy --drop-empty-elements no \
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
