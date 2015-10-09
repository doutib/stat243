### Problem 4
library(pryr)

# Clear objects from workspace
rm(list=ls(all=TRUE))

# Store data
df=as.data.frame(matrix(rnorm(1e6)*4,ncol=4))
names(df)=c("y","x1","x2","x3")
lm.fit=lm(y~.,data = df)


## a)
t_m=mem_used()
lm_size=object.size(lm.fit)
barplot(c(t_m,lm_size)/1e6,
        names.arg=c("Total","Lm"),
        ylab="MB",
        main="Memory management")


## b)

# Size of observations
obs_size=object.size(df$y)/1e6
# Lm function for our special case
lm2 = function (formula, data) 
{
  # Create a new variable which store values of memory used
  mem_management=rep(0,9)
  mem_names=c("cl","mf","m","mf2","mf3","mf4","mt","y","x")
  # Total memory used before storing the variables
  t_m=mem_used()
  # Local variables
  # 1 : cl
  cl <- match.call()
  mem_management[1]=mem_used()-t_m
  t_m=mem_used()
  # 2 : mf1
  mf <- match.call(expand.dots = FALSE)
  mem_management[2]=mem_used()-t_m
  t_m=mem_used()
  # 3 : m
  m <- match(c("formula", "data"), names(mf), 0L)
  mem_management[3]=mem_used()-t_m
  t_m=mem_used()
  # 4 : mf2
  mf <- mf[c(1L, m)]
  mem_management[4]=mem_used()-t_m
  t_m=mem_used()
  # 5 : mf3
  mf[[1L]] <- quote(stats::model.frame)
  mem_management[5]=mem_used()-t_m
  t_m=mem_used()
  # 6 : mf4
  mf <- eval(mf, parent.frame())
  mem_management[6]=mem_used()-t_m
  t_m=mem_used()
  # 7 : mt
  mt <- attr(mf, "terms")
  mem_management[7]=mem_used()-t_m
  t_m=mem_used()
  # 8 : y
  y <- model.response(mf, "numeric")
  mem_management[8]=mem_used()-t_m
  t_m=mem_used()
  # 9 : x
  x <- model.matrix(mt, mf)
  mem_management[9]=mem_used()-t_m
  t_m=mem_used()
  # Plot memory management
  barplot(mem_management/1e6,names.arg = mem_names,ylab="MB",
          main="Memory management")
  lines(x=0:11,y=rep(obs_size,12))
  text(x=3,y=obs_size+.5 ,labels = c("size of observations"))
  
  # lm.fit call
  z <- lm.fit(x, y, singular.ok = TRUE)
  class(z) <- c(if (is.matrix(y)) "mlm", "lm")
  z$xlevels <- .getXlevels(mt, mf)
  z$call <- cl
  z$terms <- mt
  z$model <- mf
  list(z,mem_management)
}
lm2(y~.,data = df)


x=as.matrix(df[,2:4])
y=as.matrix(df[,1])
t_m=mem_used()
Beta = solve(crossprod(x,x), crossprod(x,y))
beta_mem=mem_used()-t_m
# New value
beta_mem
# Plot
barplot(c(object.size(df$y),sum(lm2(y~.,data = df)[[2]]),beta_mem)/1e6,
        names.arg = c("Variables","Total before lm.fit()","Find Beta using least \n squares directly"),
        ylab="MB",main="Memory management")

