#!/bin/bash

function cxt_changed() {
    if [[ $(uname -s) == "Darwin" ]] ; then
        local stat_format="-f %m"
    elif [[ $(uname -s) == "Linux" ]] ; then
        local stat_format="-c %Y"
    else
        echo "unsupported platform: always rebuild" 1>&2
        return
    fi
    find "$1" -type f | xargs stat $stat_format | sort -nr | head -n 1
}

function img_created() {
    # find creation date of container, if present
    # NB: remove sub-second precision and convert from ISO 8601 to Unix epoch
    docker build -t test-newer - &>/dev/null <<EOF
FROM alpine:3.3
RUN apk -U add curl jq
EOF
    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock test-newer sh -c \
        "curl --fail --unix-socket /var/run/docker.sock http:/images/\$(echo $1 | jq -R -r @uri)/json 2>/dev/null \
        | jq -r '.Created[0:19]+\"Z\" | fromdate'"
}

# $1 image
# $2 source path
# return true if the image is newer than the newest file in the source tree
function img_fresh() {
    local created=$(img_created "$1")
    echo "img created: $created" 1>&2
    local changed=$(cxt_changed "$2")
    echo "cxt changed: $changed" 1>&2
    [[ -n "$changed" ]] && [[ -n "$created" ]] && (( "$created" > "$changed" ))
}

