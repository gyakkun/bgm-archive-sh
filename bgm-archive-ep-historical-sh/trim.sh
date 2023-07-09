#!/bin/bash

for i in `find ~+ -type f -name '*.html'`
do
	#echo $i
	#wc $i
	sed -i 's|<script.*</script>||g' $i
	sed -i 's|^[ \t]*||g' $i
	sed -i '/^$/d' $i
	#wc $i
done
