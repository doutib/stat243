#!/bin/bash

subset_data()
{
# arg1 = compressed data, .csv.bz2 format
# arg2 = number of random lines to get
# arg3 = regular expression
# arg4 = seed

RANDOM=$4
var=0
index=""
IFS=","
for i in $( bzcat $1 | head -1 )
do
        var=$((var+1))
                if [[ "$i" =~ $3 ]]
                        then
                        if [ -n "$index" ]
                                then
                                index=$index$","$var
                                else
                                index=$var
                        fi
                fi
done

IFS=" "

bzcat $1 | head -n 1 | cut -d',' -f $index > data.subset.csv
bzcat $1 | cut -d',' -f $index | sed '1d' | gshuf | head -$2 >> data.subset.csv

}
