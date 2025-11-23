#!/bin/sh

#export E_SLEEP_PERIOD=1.7
REST_SEC=47
while(true);do
 ./general_job.sh group ; sleep $REST_SEC
 ./general_job.sh ep; sleep $REST_SEC
done

