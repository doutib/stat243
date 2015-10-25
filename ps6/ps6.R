setwd('/Users/doutre/Documents/stat243/ps6')
getwd()
#Download
#url = 'http://www.stat.berkeley.edu/share/paciorek/1987-2008.csvs.tgz'
#download.file(url, .file)

# untar it
#untar(.file, compressed = 'bzip2', exdir = path.expand(.data))

# Create Database
library(RSQLite)
fileName="airline.db"
drv = dbDriver("SQLite")
db = dbConnect(drv, dbname = fileName)

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
con=pipe(paste("bzcat", "1987.csv.bz2"), open = 'r')
lines = read.csv(con, header = TRUE)
dbWriteTable(db, "y1987",lines)
dbSendQuery(db,"INSERT INTO airline SELECT * FROM y1987")
dbRemoveTable(db,"y1987")
close(con)
head(dbReadTable(db,"airline"))


# Write new table
dbWriteTable(db, name = "y1987", value = '1987head.csv', row.names = FALSE, header = TRUE)

# Get Fields
dbListFields(db, "y1987")
dbListFields(db, "y1988")

#Read Table
dbReadTable(db, "y1987") 
dbReadTable(db, "y1988") 

# Duplicate first table into airline
dbSendQuery(db,"CREATE TABLE airline AS SELECT * FROM y1987")
dbListTables(db)
dbReadTable(db,"airline")

# Add other tables into airline
dbSendQuery(db,"INSERT INTO airline SELECT * FROM y1988")
dbReadTable(db,"airline")

nrow(dbGetQuery(db, "SELECT * FROM y1987"))
nrow(dbGetQuery(db, "SELECT * FROM y1988"))
nrow(dbGetQuery(db, "SELECT * FROM airline"))

#delete table
dbRemoveTable(db,"airline")

#add index to database
dbSendQuery(db,"CREATE UNIQUE INDEX id_y1987 ON y1987")

dbSendQuery(db,"ALTER TABLE y1988 ADD id")
dbSendQuery(db,"CREATE UNIQUE INDEX id_y1988 ON y1987(id)")

#
file.size("./airline.db",units= "Gb")
