#!/bin/bash

curlToFile() {
	curl --connect-timeout 10 \
	    --max-time 10 \
	    --retry 6 \
	    --retry-delay 3 \
	    --retry-max-time 40 \
	    -s -L --output $2 $1
}

trimHtml() {
        sed -i 's|<script.*</script>||g' $1
        sed -i 's|^[ \t]*||g' $1
        sed -i '/^$/d' $1
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

command_exists() {
  command -v "$1" >/dev/null 2>&1
}
