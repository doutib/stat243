#setwd('/Users/doutre/Documents/stat243/ps6')

#Download
print('Downloading files...')
url = 'http://www.stat.berkeley.edu/share/paciorek/1987-2008.csvs.tgz'
download.file(url, ".file")

# Untar
print('Untar files...')
untar(".file", compressed = 'bzip2', exdir = "./data/")

# Create Database
print('Creating Database...')
library(RSQLite)
drv <- dbDriver("SQLite")
db <- dbConnect(drv, dbname = "airline.db")

# Create airline Table
dbSendQuery(conn = db,
            "CREATE TABLE airline
          ( Year                    INTEGER,
            Month                   INTEGER,
            DayofMonth              INTEGER,
            DayOfWeek               INTEGER,
            DepTime                 INTEGER,
            CRSDepTime              INTEGER,
            ArrTime                 INTEGER,
            CRSArrTime              INTEGER,
            UniqueCarrier           CHAR(4),
            FlightNum               INTEGER,
            TailNum                 INTEGER,
            ActualElapsedTime       INTEGER,
            CRSElapsedTime          INTEGER,
            AirTime                 INTEGER,
            ArrDelay                INTEGER,
            DepDelay                INTEGER,
            Origin                  CHAR(3),
            Dest                    CHAR(3),
            Distance                INTEGER,
            TaxiIn                  INTEGER,
            TaxiOut                 INTEGER,
            Cancelled               INTEGER,
            CancellationCode        INTEGER,
            Diverted                INTEGER,
            CarrierDelay            INTEGER,
            WeatherDelay            INTEGER,
            NASDelay                INTEGER,
            SecurityDelay           INTEGER,
            LateAircraftDelay       INTEGER)"
)

# Append years into airline table
print('Completing database...')
for (i in 1987:2008){
  print(paste('Year',i,'in progress...'))
  con=pipe(paste("bzcat ./data/",i,".csv.bz2",sep=""), open = 'r')
  lines = read.csv(con, header = TRUE)
  dbWriteTable(db, paste("y",i,sep=""),lines)
  dbSendQuery(db,paste("INSERT INTO airline SELECT * FROM y",i,sep=""))
  dbRemoveTable(db,paste("y",i,sep=""))
  close(con)
}
print('Done')

# Size in Gb
print('Size of Database:')
file.size("./airline.db")/2^30

# Delete database
#file.remove("./airline.db")




