#!/bin/bash
for a in $(curl http://www1.ncdc.noaa.gov/pub/data/ghcn/daily/ | grep .'\.txt' | sed -n -e 's/.*href=" *//p' | sed -n -e 's/\">.*//p')
do
curl -o $a "http://www1.ncdc.noaa.gov/pub/data/ghcn/daily/"$a
echo "Download [file : "$a"] in progress..."
done



