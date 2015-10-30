
# Load Database
print('Loading db...')
library(RSQLite)
fileName="airline.db"
drv = dbDriver("SQLite")
db = dbConnect(drv, dbname = fileName)

library(doParallel)
library(foreach)

nCores <- 4 # to set manually
registerDoParallel(nCores) 

system.time({
  out=foreach(i = c(-1,180,60,30), .combine = c) %dopar% {
    if (i==-1){
      db0=dbConnect(drv, dbname = fileName)
      s=dbGetQuery(db0," SELECT 
                   Origin, 
                   Dest,
                   substr('Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec ', (Month * 4) - 3, 3) AS Month,
                   substr('Mon Tue Wed Thu Fri Sat Sun ', (DayOfWeek * 4) - 3, 3) AS Day,
                   ROUND(CRSDepTime/100) AS Hour
                   FROM airline1 
                   GROUP BY Origin, Dest, Month, Day, Hour")
      return(s)
      close(db0)
    }
    db1=dbConnect(drv, dbname = fileName)
    s=dbGetQuery(db1,paste("
                           SELECT 
                           coalesce(round(count(case when DepDelay >",i," then 1 end)/(count(DepDelay)+.0)*100), 0) as PercentageDelay",i,"
                           FROM airline1 
                           GROUP BY Origin, Dest, Month, DayOfWeek, ROUND(CRSDepTime/100)",sep=""))
    return(s)
    close(db1)
  }
  
  dbWriteTable(db,"summary",as.data.frame(out))
})
