#!/bin/bash

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <content> <cut>"
  exit 1
fi

content=$1
cut=$2

echo "Input 1 file: $content"
trimmed_content=$(echo "$content" | xargs)
result=${trimmed_content:0:${#trimmed_content}-$cut}
export RESULT_READ_TMP_FILE=$result
echo $RESULT_READ_TMP_FILE


