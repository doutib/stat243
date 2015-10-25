
# Load Database
print('Loading db...')
library(RSQLite)
fileName="airline.db"
drv = dbDriver("SQLite")
db = dbConnect(drv, dbname = fileName)

# Create index
dbSendQuery(db,"CREATE INDEX index_name ON airline1 (Origin,Dest,Month,DayOfWeek,CRSDepTime,DepDelay)")

# Create required table with percentage of DepDelays >30
print('Aggregating DepDelay>30...')
system.time(
  dbSendQuery(db,"CREATE TABLE Delay30I AS
              SELECT 
              Origin, 
              Dest,
              substr('Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec ', (Month * 4) - 3, 3) AS Month,
              substr('Mon Tue Wed Thu Fri Sat Sun ', (DayOfWeek * 4) - 3, 3) AS Day,
              ROUND(CRSDepTime/100) AS Hour,
              coalesce(round(count(case when DepDelay > 30 then 1 end)/(count(DepDelay)+.0)*100), 0) as PercentageDelay
              FROM airline1 
              GROUP BY Origin, Dest, Month, Day, Hour")
  )
# Create required table with percentage of DepDelays >60
print('Aggregating DepDelay>60...')
system.time(
  dbSendQuery(db,"CREATE TABLE Delay60I AS
              SELECT 
              Origin, 
              Dest,
              substr('Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec ', (Month * 4) - 3, 3) AS Month,
              substr('Mon Tue Wed Thu Fri Sat Sun ', (DayOfWeek * 4) - 3, 3) AS Day,
              ROUND(CRSDepTime/100) AS Hour,
              coalesce(round(count(case when DepDelay > 60 then 1 end)/(count(DepDelay)+.0)*100), 0) as PercentageDelay
              FROM airline1 
              GROUP BY Origin, Dest, Month, Day, Hour")
  )
# Create required table with percentage of DepDelays >180
print('Aggregating DepDelay>180...')
system.time(
  dbSendQuery(db,"CREATE TABLE Delay180I AS
              SELECT 
              Origin, 
              Dest,
              substr('Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec ', (Month * 4) - 3, 3) AS Month,
              substr('Mon Tue Wed Thu Fri Sat Sun ', (DayOfWeek * 4) - 3, 3) AS Day,
              ROUND(CRSDepTime/100) AS Hour,
              coalesce(round(count(case when DepDelay > 180 then 1 end)/(count(DepDelay)+.0)*100), 0) as PercentageDelay
              FROM airline1 
              GROUP BY Origin, Dest, Month, Day, Hour")
  )