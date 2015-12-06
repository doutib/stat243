library(actuar)

# Plot
x=seq(1,10,by=0.1)
plot(x,dpareto(x,shape=3,scale=2),type="l",col="red",ylab="density",main="Density comparison")
lines(x,dexp(x),col="blue")
legend("topright",c("pareto(2,3)","exp(1)"),col=c("red","blue"),pch="--")

# Moment estimation
f = function(x){
  dexp(x-2)
}
g = function(x){
  dpareto(x,shape=3,scale=2)
}
w=function(x){
  f(x)/g(x)
}
h1=function(x){
  x*w(x)
}
h2=function(x){
  (x^2)*w(x)
}
m=10000
sample=rpareto(m,shape=3,scale=2)
#E(X)
mean(h1(sample))
#E(X2)
mean(h2(sample))
#plot
plot.new()
par(mfrow=c(1,3))
hist(h1(sample),xlab="xf(x)/g(x)",main="")
hist(h2(sample),xlab="x2f(x)/g(x)",main="")
hist(w(sample),xlab="f(x)/g(x)",main="")
title("Monte Carlo Histograms",outer=T,line=-3)
#maxweight
max(w(sample))

# Exchange f and g
f = function(x){
  dpareto(x,shape=3,scale=2)
}
g = function(x){
  dexp(x-2)
}
w=function(x){
  f(x)/g(x)
}
h1=function(x){
  x*w(x)
}
h2=function(x){
  (x^2)*w(x)
}
m=10000
set.seed(6)
sample=rexp(m)+2
#E(X)
mean(h1(sample))
#E(X2)
mean(h2(sample))
#plot
plot.new()
par(mfrow=c(1,3))
hist(h1(sample),xlab="xf(x)/g(x)",main="")
hist(h2(sample),xlab="xf(x)/g(x)",main="")
hist( w(sample),xlab="f(x)/g(x) ",main="")
title("Monte Carlo Histograms",outer=T,line=-3)
par(mfrow=c(1,1))
#maxweight
max(w(sample))

