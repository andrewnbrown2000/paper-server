#!/bin/bash


LOG_FILE="/usr/local/paper_server/logs/latest.log" #has to be the full path not w/ (pwd) bc when run from the service it will get the services pwd

AUTH_LOGS=$(grep "\[User Authenticator #[0-9]*/INFO\]" "$LOG_FILE") #pattern match auth logs
LEAVE_LOGS=$(grep "\[Server thread/INFO\]: .*left the game" "$LOG_FILE") #pattern match leave logs

#check if AUTH_LOGS is empty before counting lines
if [ -z "$AUTH_LOGS" ]; then
    AUTH_COUNT=0
else
    AUTH_COUNT=$(echo "$AUTH_LOGS" | wc -l)
fi

#check if LEAVE_LOGS is empty before counting lines
if [ -z "$LEAVE_LOGS" ]; then
    LEAVE_COUNT=0
else
    LEAVE_COUNT=$(echo "$LEAVE_LOGS" | wc -l)
fi

#compare the counts, shutdown if they match
if [ $((AUTH_COUNT - LEAVE_COUNT)) -eq 0 ]; then
    sudo shutdown -h now
fi
