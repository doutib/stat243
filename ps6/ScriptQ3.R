# Load Database
print('Loading db...')
library(RSQLite)
fileName="airline.db"
drv = dbDriver("SQLite")
db = dbConnect(drv, dbname = fileName)

# Create a new table from subsetting airline
print('Creating a subset of airline...')
dbSendQuery(db, "CREATE TABLE airline1 AS 
            SELECT *
            FROM   airline
            WHERE  DepDelay > -30
            AND DepDelay < 720
            AND DepDelay != 'NA'")

# Create index
print('Creating Index...')
dbSendQuery(db,"CREATE INDEX index_name ON airline1 (Origin,Dest,Month,DayOfWeek,CRSDepTime,DepDelay)")

# Begin parallel programming
library(foreach)
library(doMC)

# Set up 4 cores 
registerDoMC(cores = 4)

system.time({
  print('computing aggregation...')
  out=foreach(i = c(-1,180,60,30), .combine = c) %dopar% {
    if (i==-1){
      db0=dbConnect(drv, dbname = fileName)
      s=dbGetQuery(db0," SELECT 
                   Origin, 
                   Dest,
                   substr('Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec '
                   ,(Month * 4) - 3, 3) AS Month,
                   substr('Mon Tue Wed Thu Fri Sat Sun ', (DayOfWeek * 4) - 
                   3, 3) AS Day,
                   ROUND(CRSDepTime/100) AS Hour
                   FROM airline1 
                   GROUP BY Origin, Dest, Month, Day, Hour")
      return(s)
      dbDisconnect(db0)
    }
    else{
      db1=dbConnect(drv, dbname = fileName)
      s=dbGetQuery(db1,paste("
                             SELECT 
                             coalesce(round(count(case when DepDelay >",i,
                             " then 1 end)/(count(DepDelay)+.0)*100), 0) as 
                             PercentageDelay",i,"
                             FROM airline1 
                             GROUP BY Origin, Dest, Month, DayOfWeek, 
                             ROUND(CRSDepTime/100)",sep=""))
      return(s)
      dbDisconnect(db1)
    }
  }
  print('writing table...')
  dbWriteTable(db,"summary",as.data.frame(out))
})
