#!/bin/bash 
set -x

cat slack_payload.json | jq -cr ".attachments[0].blocks[0].text.text = \"*JOB:* JOB_NAME, *BUILD:* BUILD_NUM\n\"" | jq -cr ".text = \"*<example.com|Jenkins DevOps Pipeline Failed!>*\"" | jq -c . > slack.json

curl -X POST -H 'Content-type: application/json' --data '@slack.json' https://hooks.slack.com/services/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