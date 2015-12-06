# Helical valley
theta <- function(x1,x2) atan2(x2, x1)/(2*pi)

f <- function(x) {
  f1 <- 10*(x[3] - 10*theta(x[1],x[2]))
  f2 <- 10*(sqrt(x[1]^2+x[2]^2)-1)
  f3 <- x[3]
  return(f1^2+f2^2+f3^2)
}

a=0 #Define slice
f1 = function(x2,x3){
  m=cbind(x2,x3)
  apply(m,1,function(row) f(c(a,row)))
}

b=5 #Define slice
f2 = function(x1,x3){
  m=cbind(x1,x3)
  apply(m,1,function(row) f(c(row[1],b,row[2])))
}

c=5 #Define slice
f3 = function(x1,x2){
  m=cbind(x1,x2)
  apply(m,1,function(row) f(c(row,c)))
}

x=seq(-10,10,by=0.5)
persp(x,x,outer(x,x,f1),phi=20,theta=-15)
persp(x,x,outer(x,x,f2),phi=20,theta=-60)
persp(x,x,outer(x,x,f3),phi=20,theta=-60)

# Results
x_init=c(1,1,1)
optim(x_init,f)
max(abs(optim(x_init,f)$par-nlm(f,x_init)$estimate)) #similar

# Different starting point
x_init=c(-20,100,1)
optim(x_init,f) 
optim(x_init,f)$par-nlm(f,x_init)$estimate #different estimate



