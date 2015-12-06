set.seed(1)
library(robust)

# Generate data 
n=30
p=4
beta = matrix(c(.5,1,0,0),ncol=1)
X = cbind(1,rnorm(n,sd=4),rnorm(n,sd=.2),rnorm(n,sd=.2))
Y = X%*%beta+matrix(rnorm(n),ncol=1) #Good data
Y[sample(1:n,n/10)] = Y[sample(1:n,n/10)] + rnorm(0,40,n=n/10) #Bad data 10%
plot(X[,2],Y,main="Generated data")

################# OLS ######################
plot(X[,2],Y,main="OLS Regression")

# Bootsrap sample
B=10000
r=n
OLSbetastar=matrix(nrow=B,ncol=p)
for (b in 1:B){
  s=sample(1:n,r,replace=T)
  Xstar=X[s,]
  Ystar=Y[s]
  OLSbetastar[b,]=lm(Ystar~Xstar[,-1])$coefficients
}

# Bootsrapped estimates
OLSbetastar_hat=apply(OLSbetastar,2,mean)
sum(abs(Y-X%*%OLSbetastar_hat)) # Absolute error
for (row in 1:n){
  abline(OLSbetastar[row,1:2],col="darkgray",lwd=0.3)
}
abline(OLSbetastar_hat[1:2],lwd=1.3)

# Bootstrapped confint 95%
SE=apply(OLSbetastar,2,sd)
borne_sup=OLSbetastar_hat+qnorm(1-.05/2)*SE
borne_inf=OLSbetastar_hat-qnorm(1-.05/2)*SE
abline(borne_sup[1:2],lty=3)
abline(borne_inf[1:2],lty=3)

# True beta
abline(beta[1:2],col="blue")

legend("bottomleft",c("Truth","Estimate","confidence interval"),
       lty=c(1,1,3),col=c("blue","black","black"))

# Coverage prediction
mean(apply(OLSbetastar,1,function(row) Reduce('*',row>borne_inf && row<borne_sup)))

################# ROBUST ######################
plot(X[,2],Y,main="Robust Regression")

# Bootsrap sample
B=1000
r=n
betastar=matrix(nrow=B,ncol=p)
for (b in 1:B){
  s=sample(1:n,r,replace=T)
  Xstar=X[s,]
  Ystar=Y[s]
  betastar[b,]=lmrob(Ystar~Xstar[,-1],tau=.5)$coefficients
}

# Bootsrapped estimates
betastar_hat=apply(betastar,2,mean)
sum(abs(Y-X%*%betastar_hat)) # Absolute error
for (row in 1:n){
  abline(betastar[row,1:2],col="darkgray",lwd=0.3)
}
abline(betastar_hat[1:2],lwd=1.3)

# Bootstrapped confint 95%
SE=apply(betastar,2,sd)
borne_sup=betastar_hat+qnorm(1-.05/2)*SE
borne_inf=betastar_hat-qnorm(1-.05/2)*SE
abline(borne_sup[1:2],lty=3)
abline(borne_inf[1:2],lty=3)

# True beta
abline(beta[1:2],col="blue")

legend("bottomleft",c("Truth","Estimate","confidence interval"),
       lty=c(1,1,3),col=c("blue","black","black"))

# Coverage prediction
mean(apply(betastar,1,function(row) Reduce('*',row>borne_inf && row<borne_sup)))

sum(abs(Y-X%*%betastar_hat)) # LMROB_boot Absolute error
sum(abs(Y-X%*%OLSbetastar_hat)) # OLS Absolute error
