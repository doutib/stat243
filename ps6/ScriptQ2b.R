
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

# Create required table with percentage of DepDelays >30
print('Aggregating DepDelay>30...')
system.time(
dbSendQuery(db,"CREATE TABLE Delay30 AS
  SELECT 
           Origin, 
           Dest,
           substr('Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec ', (Month * 4) - 3, 3) AS Month,
           substr('Mon Tue Wed Thu Fri Sat Sun ', (DayOfWeek * 4) - 3, 3) AS Day,
           ROUND(CRSDepTime/100) AS Hour,
           coalesce(round(count(case when DepDelay > 30 then 1 end)/(count(DepDelay)+.0)*100), 0) as PercentageDelay,
           count(DepDelay) AS count
           FROM airline1 
           GROUP BY Origin, Dest, Month, Day, Hour")
)
# Create required table with percentage of DepDelays >60
print('Aggregating DepDelay>60...')
system.time(
dbSendQuery(db,"CREATE TABLE Delay60 AS
           SELECT 
           Origin, 
           Dest,
           substr('Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec ', (Month * 4) - 3, 3) AS Month,
           substr('Mon Tue Wed Thu Fri Sat Sun ', (DayOfWeek * 4) - 3, 3) AS Day,
           ROUND(CRSDepTime/100) AS Hour,
           coalesce(round(count(case when DepDelay > 60 then 1 end)/(count(DepDelay)+.0)*100), 0) as PercentageDelay,
           count(DepDelay) AS count
           FROM airline1 
           GROUP BY Origin, Dest, Month, Day, Hour")
)
# Create required table with percentage of DepDelays >180
print('Aggregating DepDelay>180...')
system.time(
dbSendQuery(db,"CREATE TABLE Delay180 AS
           SELECT 
           Origin, 
           Dest,
           substr('Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec ', (Month * 4) - 3, 3) AS Month,
           substr('Mon Tue Wed Thu Fri Sat Sun ', (DayOfWeek * 4) - 3, 3) AS Day,
           ROUND(CRSDepTime/100) AS Hour,
           coalesce(round(count(case when DepDelay > 180 then 1 end)/(count(DepDelay)+.0)*100), 0) as PercentageDelay,
           count(DepDelay) AS count
           FROM airline1 
           GROUP BY Origin, Dest, Month, Day, Hour")
)