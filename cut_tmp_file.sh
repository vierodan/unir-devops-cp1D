#!/bin/bash

if [ "$#" -lt 3 ]; then
  echo "Usage: $0 <content> <cut> <file>"
  exit 1
fi

content=$1
cut=$2
file=$3

echo "cut_tmp_file.sh --> Input 1 'content' value: $content"
echo "cut_tmp_file.sh --> Input 2 'cut' value: $cut"
echo "cut_tmp_file.sh --> Input 3 'file' value: $file"

trimmed_content=$(echo "$content" | xargs)
result=${trimmed_content:0:${#trimmed_content}-$cut}

echo $result > $file


