#### 1


library(pryr)
memXc=c()
memX=c()
m0=0
for (n in seq(100,1500,100)){
  X0=matrix(runif(n*n),n,n)
  X=NULL
  m0=mem_used()
  X=(X0+t(X0))/n+diag(n)
  memX=c(memX,mem_used()-m0)
  m0=mem_used()
  X=chol(X)
  memXc=c(memXc,mem_used()-m0) 
}
plot(memX/1000,type="l",xlab="n",ylab="Memory")
lines(memXc/1000,type="o")
legend("bottomright",c("memory used to store X","additional memory for Xc"),pch=c(NA,1),lty=c(1,0))
title(main = "Memory used for storing X and Xc")

#
timeXc=c()
timeX=c()
m0=0
for (n in seq(100,1500,100)){
  X0=matrix(runif(n*n),n,n)
  X=NULL
  timeX=c(timeX,system.time(  X=(X0+t(X0))/n+diag(n) ))
  timeXc=c(timeXc,system.time(  Xc=chol(X) )) 
}
plot(timeX,type="l",xlab="n",ylab="Time")
lines(timeXc,type="o")
legend("bottomright",c("X","Xc"),pch=c(NA,1),lty=c(1,0))
title(main = "Time spent for storing X and Xc")
#
names(proc.time())




#### 3
# Initialize Definite positive matrix
size=500
X0 = matrix(runif(size*size),size,size)
X=X0+t(X0)+n*diag(size)

# Initialize vector
y = matrix(runif(size),ncol=1)

# Compute elapsed time 
print('Inverse and %*%')
system.time(solve(X)%*%y)
print('Solve')
system.time(solve(X,y))
print('Cholesky')
system.time({U=chol(X);
backsolve(U, backsolve(U, y, transpose = TRUE))})

##### 4
n=100
p=10
y=matrix(runif(n),nrow=n,ncol=1)
S=diag(n)
X=chol(S)

gls = function(X,Y,S){
  # X is a nxp matrix
  # Y is a vector of length n
  # S is a covariance matrix
  P=chol(S)
  Xbis=backsolve(P,X,transpose = TRUE)
  Ybis=backsolve(P,Y,transpose = TRUE)
  V=chol(tcrossprod(Xbis,Xbis))
  backsolve(Xbis, backsolve(Xbis, crossprod(Xbis,Ybis), transpose = TRUE))
  
}
head(gls(X,y,S))

# Define n, p. Note that n > p 
n     <- 2000
p     <- 200

# For simplicity set the covariance matrix to be the identity
sigma <- diag(n)

# Define X to be the Cholesky decomposition of sigma for simplicity
X     <- chol(sigma)

# Define the y vector
y <- matrix(rnorm(n), nrow = n, ncol = 1)

# Solve the given system of equations using the above GLS function
system.time(head(gls(X,y,sigma),10))


