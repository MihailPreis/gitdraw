#!/usr/bin/env bash

set -e

INPUT_IMAGE_FILE=$1
SCRIPT_DIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)
IMAGE_FILE="$SCRIPT_DIR/image.jpg"

if [ ! -f $INPUT_IMAGE_FILE ]; then
    echo "image not be found."
    exit 1
fi

if ! command -v magick &> /dev/null; then
    echo "magick could not be found"
    exit 1
fi

if [ -f $IMAGE_FILE ]; then
    rm "$IMAGE_FILE"
fi

convert $INPUT_IMAGE_FILE -resize 54x7\! -colorspace GRAY "$IMAGE_FILE"

echo "done"
