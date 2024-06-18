#!/bin/bash

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <file> <cut>"
  exit 1
fi

file=$1
cut=$2

echo "Input 1 file: $file"
echo "Input 2 cut: $cut"

file_content=$($file)
trimmed_content=$(echo "$file_content" | xargs)

result=${trimmed_content:0:${#trimmed_content}-$cut}

export RESULT_READ_TMP_FILE=$result

echo $RESULT_READ_TMP_FILE


