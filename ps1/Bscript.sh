#!/bin/bash

function foo1
{
wget -O test0.tar.gz "http://data.un.org/Handlers/DownloadHandler.ashx?DataFilter=itemCode:$1&DataMartId=FAO&Format=csv&c=2,3,4,5,6,7&s=countryName:asc,elementCode:asc,year:desc"	
tar -zxvf  test0.tar.gz
ls UNdata_* | xargs cat
ls UNdata_* | xargs rm
rm test0.tar.gz
}


