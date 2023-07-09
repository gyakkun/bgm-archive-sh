#!/bin/bash

command_exists() {
	command -v $1 >/dev/null 2>&1
}


for i in `find ~+ -type f -name '*.html'`
do
	if command_exists tidy; then
		echo tidying $i
                tidy    --drop-empty-elements no \
                        --tidy-mark no \
                        --wrap 0 \
                        --sort-attributes alpha \
                        --quiet yes \
                        --show-warnings no \
                        -m $i
        fi
done
