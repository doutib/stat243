library(base)
#setwd('~/Documents/stat243/ps2')
#getwd()
set.seed(0)
random=c(1,sample(2:7219001,10000))
con = bzfile("./data.csv.bz2", "r") 
system.time(scan(con,sep=',',what="integer"))
close(con)

