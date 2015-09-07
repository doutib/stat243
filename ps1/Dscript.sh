#!/bin/bash

getData(){


local locvar=$(curl "http://data.fao.org/dimension-member?entryId=8462e2d6-ba52-492c-a0a7-e08893a59aac" | grep ">Default composition" | sed -n -e 's/ '$1'.*//p' | tail -c 4)

source Bscript.sh
foo1 $locvar > $1.txt
}
