#!/bin/sh

# export E_SLEEP_PERIOD=2
# export E_BGM_DOMAIN_LIST="bgm.tv"
rest=65
while(true);do
	./general_job.sh blog
	sleep $rest
	./general_job.sh subject
	sleep $rest
	./general_job.sh character
	sleep $rest
	./general_job.sh person
	sleep $rest
done

