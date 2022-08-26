#!/bin/sh

REGEX=$1

# validate regex if not return 1
file=$2
for i in `cat $file`
do
    echo $i | grep -P -i "$REGEX" 
    echo $? $i
done
