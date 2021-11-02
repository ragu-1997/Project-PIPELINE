#!/bin/sh
set -e

# this opens the address for the first port of a task

marathonctl -f jsonpp -c marathonctl.properties task list /${1} | jq -r '.app.tasks[0].host+":"+(.app.tasks[0].ports[0]|tostring)'
