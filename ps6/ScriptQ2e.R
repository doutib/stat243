# Load Database
print('Loading db...')
library(RSQLite)
fileName="airline.db"
drv = dbDriver("SQLite")
db = dbConnect(drv, dbname = fileName)

# Query
dbGetQuery(db,"SELECT * FROM Delay180I 
           WHERE (count >150) 
           ORDER BY PercentageDelay DESC 
           LIMIT 10 ")
