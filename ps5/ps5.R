options(digits=16)
x = c(1,rep(1e-16,10000))
sum(x)
options(digits=16)
1.000000000001
options(digits=17)
1.000000000001


# ((x1 + x2) + x3) + ...
sum1=0
for (i in x)
  sum1=sum1+i
sum1
# ((xn + xn-1) + xn-2) + ...
sum2=0
for (i in length(x):1)
  sum2=sum2+x[i]
sum2

# R's sum function computes the sum by adding numbers
# from the right to the left...
sum
# We can see that sum is a primitive function :
# it calls C code directly with .Primitive() 
# and contains no R code

library(rbenchmark)
options(digits = 4)
n=10000
integers=sample(1:n,n)
integers2=sample(1:n,n)
floats=sample(1:n+0.0,n)
floats2=sample(1:n+0.0,n)

#sum
benchmark(
  int = sum(integers) ,
  float = sum(floats),
  replications = 100000,
  columns=c('test', 'elapsed', 'replications'))
#sumBis
benchmark(
  int = Reduce('+',integers) ,
  float = Reduce('+',floats),
  replications = 200,
  columns=c('test', 'elapsed', 'replications'))
#subsetting
benchmark(
  int = integers[1:100] ,
  float = floats[1:100],
  replications = 10000,
  columns=c('test', 'elapsed', 'replications'))
#substracting
benchmark(
  int = integers-integers2 ,
  float = floats-floats2,
  replications = 10000,
  columns=c('test', 'elapsed', 'replications'))
#crossproduct
benchmark(
  int = crossprod(integers,integers2) ,
  float = crossprod(floats,floats2),
  replications = 10000,
  columns=c('test', 'elapsed', 'replications'))




