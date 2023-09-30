#!/usr/bin/env bash

_date=$(date -v -378d +%s)

for i in $(seq 0 377); do
    if [[ $i > 0 ]]; then
        _d=$(./gitdraw.sh $(date -r $_date -v +${i}d +%s))
        echo $(echo $_d | tail -n 1)
    else
        _d=$(./gitdraw.sh $(date -r $_date +%s))
        echo $(echo $_d | tail -n 1)
    fi
done
