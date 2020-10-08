#!/bin/bash 
set -x

cat slack_payload.json | jq -cr ".attachments[0].blocks[0].text.text = \"*JOB:* $1, *BUILD:* $2\n\"" | jq -cr ".text = \"*<$3 | Jenkins DevOps Pipeline Failed!>*\"" | jq -c . > slack.json

curl -X POST -H 'Content-type: application/json' --data '@slack.json' $4