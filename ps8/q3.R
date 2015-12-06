set.seed(1)
# Auxiliaries functions
Estep=function(x,y,beta){
  z=matrix(0,ncol=1,nrow=length(y))
  for (i in 1:length(y)){
    xi=x[i,]
    xib=crossprod(xi,beta)
    if (y[i]==0){
      z[i,]=xib-dnorm(xib)/(pnorm(-xib))
    }
    else{
      z[i,]=xib+dnorm(xib)/(1-pnorm(-xib))
    }
  }
  return(z)
}
Mstep =function(X,Z){
  as.matrix(lm(Z~X[,-1])$coefficients,ncol=1)
}

# EM
em = function(X,beta0,eps,plot=F){
  beta_old=beta0
  beta=beta0
  nit=0
  while (nit==0 | sum((beta_old-beta)^2)/sum((beta_old)^2)>eps){
    beta_old=beta
    if(plot)
      abline(beta[1:2])
    Z=Estep(X,Y,beta)
    beta=Mstep(X,Z)
    Y=as.numeric(Z>0)
    nit=nit+1
  }
  return(list(beta=beta,nit=nit))
}

# Generate data 
beta = matrix(c(.5,1,0,0),ncol=1)
X = cbind(1,rnorm(100,sd=.5),rnorm(100,sd=2),rnorm(100,sd=2))
Z = X%*%beta+matrix(rnorm(100),ncol=1)
Y=as.numeric(Z>0) # Observed data
plot(X[,2],Z,main="EM probit")

# Initialize Beta
beta0=apply(X,2,mean)
# Run EM
em(X,beta0,1e-5,plot=T)

# Alternative
# data
beta = matrix(c(.5,1,0,0),ncol=1)
X = cbind(1,rnorm(100,sd=.5),rnorm(100,sd=2),rnorm(100,sd=2))
Z = X%*%beta+matrix(rnorm(100),ncol=1)
Y=Z # Observed data

# BFGS
loss = function(beta){
  r=Y-X%*%beta
  sum(r^2)/2
}
grad = function(beta){
  -crossprod(X,Y-X%*%beta)
}
beta0=apply(X,2,mean)
opt=optim(par=beta0,fn=loss,gr=grad,method="BFGS")
opt

# Standard errors
beta_hat=opt$par
sqrt(diag(sum((Y-X%*%beta_hat)^2)/(100-4)*solve(crossprod(X,X))))


# Less iterations for EM 7 against 30 here
