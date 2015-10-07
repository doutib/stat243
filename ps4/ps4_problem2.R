### Problem 2
setwd("/Users/doutre/Documents/stat243/ps4")
library(fields)
library(rbenchmark)

## Global variables
p = 0.3
φ = 0.5

## a)
# log scale
# if we don t use the logscale, it is much longer it will return inf
log_f = function(k,n,p,φ){
  if (k==0 || k==n)
    return((n-k)*φ*log(1-p)+ k*φ*log(p) )
  else
    return(lchoose(n,k)+ 
             (1-φ)*(k*log(k) + (n-k)*log(n-k) - n*log(n))+ 
             φ*(k*log(p) + (n-k)*log(1-p)))
}

# using lapply
sum_f = function(n,p,φ){
  l = as.list(0:n)
  fk = lapply(l,function(k) exp(log_f(k,n,p,φ)))
  return(Reduce("+",fk))
}
# Example
sum_f(200,p,φ)

Rprof("sum_f.txt")
out=sum_f(200000,p,φ)
Rprof(NULL)
summaryRprof("sum_f.txt")$by.self

## b)

sum_f_vect = function(n,p,φ){
  ones=matrix(1,nrow=n-1,ncol=1)
  v=1:(n-1)
  n_v= -v
  n_and_n_v=(n+n_v)
  phi_phiBis=exp(-log(1/φ-1))
  s_bounds = exp((lgamma(n+1)-(lgamma(v+1)+lgamma(n+n_v+1)))+
                   (1-φ)*(v*(log(v)+log(p)*phi_phiBis) + 
                   n_and_n_v*(log(n_and_n_v)+phi_phiBis*log(1-p)) - 
                   n*log(n)))
  return( exp((n*φ)*log((1-p)*p))+crossprod(s_bounds,ones))
}

sum_f_vect(200,p,φ)

Rprof("sum_f.txt",interval = 1e-5)
out=sum_f_vect(1e7,p,φ)
Rprof(NULL)
summaryRprof("sum_f.txt")$by.self

benchmark(
  out = sum_f(200,p,φ) ,
  out_vect = sum_f_vect(200,p,φ),
  replications = 10000,
  columns=c('test', 'elapsed', 'replications'))

microbenchmark(sum_f_vect(2000,p,φ))
