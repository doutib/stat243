### Problem 3

setwd("/Users/doutre/Documents/stat243/ps4")
load("./mixedMember.Rda")
head(IDsA)
head(muA)
head(wgtsA)
head(IDsB)
head(muB)
head(wgtsB)
library(rbenchmark)
library(fields)
library(plyr)
library(Matrix)
library(microbenchmark)


## Global variables
n=length(IDsA) #IDsB has the same length

## a)

# For A
outA = sapply(1:n,function(i) sum(wgtsA[[i]]*muA[IDsA[[i]]]))
# For B
outB = sapply(1:n,function(i) sum(wgtsB[[i]]*muB[IDsB[[i]]]))

# speed calculation
benchmark(
  outA=sapply(1:n,function(i) sum(wgtsA[[i]]*muA[IDsA[[i]]])),
  outB=sapply(1:n,function(i) sum(wgtsB[[i]]*muB[IDsB[[i]]])), 
  replications = 10,
  columns=c('test', 'elapsed', 'replications'))


## b and c)

# Transform function : add zeros in the middle
transform_ID = function(l,max.len){
  M=matrix(rep(0,max.len*length(l)),nrow=max.len)
  for (i in 1:length(l)){
    li=l[[i]]
    M[li,i]=1
  }
  return(M)
}
# Transform W 
transform_W = function(l,ID_transformed){
  M=ID_transformed
  for (i in 1:length(l)){
    li=l[[i]]
    M[,i][M[,i] != 0]=li
  }
  return(M)
}
# Do the permutation on W instead of mu
permutation_W = function(wgtsB_transformed,ID){
  l=wgtsB_transformed
  for (i in 1:length(ID)){
    l[,i][ID[[i]]]=wgtsB_transformed[,i][ID[[i]][order(ID[[i]])]]
  }
  return(l)
}
# Deal with sparse matrices, for A especially
transform_data_sparse = function(wgts,IDs,max.len){
  ID_transformed=transform_ID(IDs,max.len)
  wgts_transformed=transform_W(wgts,ID_transformed)
  new_data=permutation_W(wgts_transformed,IDs)
  new_data_sparse_bis=as(new_data,"sparseMatrix")
  new_data_sparse=Matrix(new_data_sparse_bis, sparse = TRUE)
  return(new_data_sparse)
}
# Normal matrices, for B
transform_data = function(wgts,IDs,max.len){
  ID_transformed=transform_ID(IDs,max.len)
  wgts_transformed=transform_W(wgts,ID_transformed)
  new_data=permutation_W(wgts_transformed,IDs)
  return(new_data)
}

new_data_B=transform_data(wgtsB,IDsB,length(muB))
new_data_A=transform_data_sparse(wgtsA,IDsA,length(muA))

# Compute sums in a vectorized way
#sparse matrices, for A
vect_sum_sparse = function(new_data, mu){ 
  ones= Matrix(1,nrow=length(mu),ncol=1,sparse = TRUE)
  product=new_data*mu
  res=crossprod(ones,product)
  return(res)
}
# normal, for B
vect_sum = function(new_data, mu){ 
  ones= matrix(1,nrow=length(mu),ncol=1)
  product=new_data*mu
  res=crossprod(ones,product)
  return(res)
}

Rprof("vect_sum2.txt",interval = 0.000005)
out=vect_sum_sparse(new_data_A,muA)
Rprof(NULL)
summaryRprof("vect_sum2.txt")

## d)

# speed calculation with benchmark
benchmark(
  outA = sapply(1:n,function(i) sum(wgtsA[[i]]*muA[IDsA[[i]]])),
  outB = sapply(1:n,function(i) sum(wgtsB[[i]]*muB[IDsB[[i]]])),
  outA_vect=vect_sum_sparse(new_data_A,muA),
  outB_vect=vect_sum(new_data_B,muB),
  replications = 10,
  columns=c('test', 'elapsed', 'replications'))

# speed calculation with microbenchmark
microbenchmark(
  outA = sapply(1:n,function(i) sum(wgtsA[[i]]*muA[IDsA[[i]]])),
  outB = sapply(1:n,function(i) sum(wgtsB[[i]]*muB[IDsB[[i]]])),
  outA_vect=vect_sum_sparse(new_data_A,muA),
  outB_vect=vect_sum(new_data_B,muB),
  times = 10L
)

# speed calculation with system.time
print("outA")
system.time(sapply(1:n,function(i) sum(wgtsA[[i]]*muA[IDsA[[i]]])))
print("outB")
system.time(sapply(1:n,function(i) sum(wgtsA[[i]]*muA[IDsA[[i]]])))
print("outA_vect2")
system.time(vect_sum_sparse(new_data_A,muA))
print("outB_vect2")
system.time(vect_sum(new_data_B,muB))



############################# first try for b ######################

# Transform function : add zeros
transform_matrix0 = function(l,max.len){
  M=matrix(rep(0,max.len*length(l)),ncol=max.len)
  for (i in 1:length(l)){
    li=l[[i]]
    M[i,1:length(li)]=li
  }
  return(M)
}
# Let's transform the data
transform_data0 = function (IDsA,muA,wgtsA){
  # Get max length
  max.len = max(unlist(lapply(IDsA,length)))
  #Get W
  W=transform_matrix0(wgtsA,max.len)
  # Get MU
  MU=transform_matrix0(lapply(IDsA,function(x) x=muA[x]),max.len)
  return(list(W=W,MU=MU,max.len=max.len))
}
A_transformed = transform_data0(IDsA,muA,wgtsA)
B_transformed = transform_data0(IDsB,muB,wgtsB)

# Compute sums in a vectorized way
vect_sum0 = function(data_transformed){
  MU=data_transformed$MU
  W=data_transformed$W
  max.len=data_transformed$max.len
  ones= matrix(1,ncol=max.len,nrow=1)
  product=MU*W
  res=tcrossprod(product, ones)
  return(res)
}

Rprof("vect_sum.txt",interval = 0.000005)
out=vect_sum0(A_transformed)
Rprof(NULL)
summaryRprof("vect_sum.txt")
###############################################################
