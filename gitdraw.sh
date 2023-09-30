#!/usr/bin/env bash
export LC_NUMERIC="en_US.UTF-8"

CURRENT_DATE_TS=${1:-$(date +%s)}

IMAGE_FILE="image.jpg"
CONF_FILE=".data"

MIN_COMMIT_COUNT=1
MAX_COMMIT_COUNT=10

MIN_RGB=0
MAX_RGB=255

if [ ! -f $IMAGE_FILE ]; then
    echo "image not be found. please create monochrome image with 54x7 size"
    exit 1
fi

if ! command -v magick &> /dev/null; then
    echo "magick could not be found"
    exit 1
fi

function _readimagepixel {
    PIXEL_RAW=$(magick $IMAGE_FILE -format "%[pixel:p{$1,$2}]" info:)
    re='srgb\(([0-9]+),([0-9]+),([0-9]+)\)'

    if [[ $PIXEL_RAW =~ $re ]]; then
        RED="${BASH_REMATCH[1]}"
        GREEN="${BASH_REMATCH[2]}"
        BLUE="${BASH_REMATCH[3]}"

        result=$(( ($RED + $GREEN + $BLUE) / 3 ))
        result=$(bc <<< "scale=4; ($result - $MIN_RGB) / ($MAX_RGB - $MIN_RGB) * ($MAX_COMMIT_COUNT - $MIN_COMMIT_COUNT) + $MIN_COMMIT_COUNT")
        result=$(printf "%.0f\n" $result)
        result=$(( (10 - $result) + 1 ))

        echo "$result"
    else
        echo "$MIN_COMMIT_COUNT"
    fi
}

function _flush {
    echo "$1" > $CONF_FILE
    echo "$2" >> $CONF_FILE
    echo "$3" >> $CONF_FILE
    echo "$RANDOM" >> $CONF_FILE

    git add $CONF_FILE &> /dev/null
    git commit -m "$2" --date "$2" &> /dev/null
}

if [ -f $CONF_FILE ]; then
    echo "conf file is exist. go go go"

    _START_DATE=$(sed -n '1p' $CONF_FILE)
    _LAST_DATE=$(sed -n '2p' $CONF_FILE)
    _WEEK_COUNT=$(sed -n '3p' $CONF_FILE)

    _LAST_WOY=$(date -r $_LAST_DATE +%U)
    _LAST_WOY=$((10#$_LAST_WOY))

    _CURRENT_DOW=$(date -r $CURRENT_DATE_TS +%u)
    _CURRENT_WOY=$(date -r $CURRENT_DATE_TS +%U)
    _CURRENT_WOY=$((10#$_CURRENT_WOY))

    if [ $(date -r $CURRENT_DATE_TS +%F) == $(date -r $_LAST_DATE +%F) ]; then
        echo "already draw today. skip."
        exit 0
    fi

    if [[ $_CURRENT_WOY -gt $_LAST_WOY ]]; then
        echo "_CURRENT_WOY=$_CURRENT_WOY _LAST_WOY=$_LAST_WOY"
        _WEEK_COUNT=$(( $_WEEK_COUNT + ($_CURRENT_WOY - $_LAST_WOY) ))
    elif [[ $_CURRENT_WOY -lt $_LAST_WOY ]]; then
        _WEEK_COUNT=$(( $_WEEK_COUNT + 1 ))
    fi
    
    week_count=$(( $_WEEK_COUNT % 54 ))

    cur_dow=$_CURRENT_DOW
    if [[ $_CURRENT_DOW -eq 7 ]]; then 
        cur_dow=0
    fi

    commit_count=$(_readimagepixel $week_count $cur_dow)
    for i in $(seq 1 $commit_count); do 
        _flush "$_START_DATE" "$(date -r $CURRENT_DATE_TS +%s)" "$_WEEK_COUNT"
    done
    echo "$commit_count"
else
    echo "conf file not exist. check if do start"

    if [ $(date -r $CURRENT_DATE_TS +%u) -ne 1 ]; then
        echo "now is not the time to start"
        exit 0
    fi

    echo "IT'S TIME BEGIN!!1"

    commit_count=$(_readimagepixel 0 0)
    for i in $(seq 1 $commit_count); do 
        _flush "$(date -r $CURRENT_DATE_TS +%s)" "$(date -r $CURRENT_DATE_TS +%s)" 0
    done
    echo "$commit_count"
fi
