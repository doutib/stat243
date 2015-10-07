## Problem 1

## a)

set.seed(0) 
runif(1)
r=.Random.seed
save(.Random.seed, file = 'tmp.Rda')
runif(1)
# random seed immediately after having loaded tmp.Rda
# and computed runif(1)
 

load('tmp.Rda') 
runif(1)

set.seed(0)
# Debug
tmp <- function() { 
  load('tmp.Rda')
  print(identical(.Random.seed,.GlobalEnv$.Random.seed))
  runif(1)
} 
tmp()
# since we have loaded the file
# and computed runif(1)
# r should be equal to the random seed
identical(.Random.seed,r)

## b)

# Good function
tmp <- function() { 
  load('tmp.Rda',envir = globalenv())
  runif(1)
} 
tmp()


