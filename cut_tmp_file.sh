#!/bin/bash

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <content> <cut>"
  exit 1
fi

content=$1
cut=$2

echo "cut_tmp_file.sh --> Input 1 'content' value: $content"
echo "cut_tmp_file.sh --> Input 2 'cut' value: $cut"
trimmed_content=$(echo "$content" | xargs)
result=${trimmed_content:0:${#trimmed_content}-$cut}
export RESULT_READ_TMP_FILE=$result
echo "Result of cut_tmp_file.sh execution --> result $RESULT_READ_TMP_FILE"


