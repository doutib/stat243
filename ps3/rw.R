#####FUNCTION
random_walk = function (n,out="",plot=T,origin=c(0,0),
                        legend="bottomright"){
  if (!is.numeric(n)){
    stop("\"n\" is not a number")
  }
  else if (!(floor(n)==n)){
    stop("\"n\" is not an integer")
  }
  else if (!(n>0)){
    stop("\"n\" is not positive")
  }
  else{
    x=c(0,cumsum(rbinom(n,1,0.5)-0.5)*2)+origin[1]
    y=c(0,cumsum(rbinom(n,1,0.5)-0.5)*2)+origin[2]
    #Plotting Options
    if (plot){
      ymax=max(y)
      ymin=min(y)
      xmax=max(x)
      xmin=min(x)
      plot(x,y,ylim=c(ymin,ymax),xlim=c(xmin,xmax),type="b",
           cex=rev(seq(.5,2,1.5/n)),col=gray(rev(seq(0,0.5,0.5/n)))
           ,pch=19,main=cat("Random Walk, ", n, " steps"))
      segments(x[1:(n-1)],y[1:(n-1)],x[2:n],y[2:n],lwd=0.8)
      points(x[1],y[1],pch=9,cex=3)
      points(x[n+1],y[n+1],pch=3,cex=6)
      legend( x=legend, 
              legend=c("Initial Position","Final Position"),
              pch=c(9,3) )
    }
    #Return the path of the random walk
    if (out=="path")
      return(cbind(x,y))
    #Return the last position of the random walk olny
    if (out == "last")
      return(c(x[n+1],y[n+1]))
  }
}
set.seed(11)
random_walk(10000)
######################################## S3 #################################

## @knitr constructor
rw <- function(steps=NA,origin=c(0,0)){
  # constructor for 'indiv' class
  obj <- list(steps=steps,origin=origin)
  class(obj) <- 'rw' 
  return(obj)
}


## @knitr methods
print.rw <- function(object) 
  return(random_walk(object$steps,plot=F,out="last",origin=object$origin))
plot.rw <- function(object,legend="bottomright") 
  return(random_walk(object$steps,plot=T,out="",origin=object$origin,legend=legend))
summarize.rw <- function(object) 
  return(with(object, cat("Random walk with ", steps, 
                          " steps and origin (", origin[1],",",origin[2],").\n",
                          sep = "")))

## @knitr class-operators
`[.rw` <- function(object,i) {
  r=random_walk(object$steps,origin=object$origin,plot=F,out="path")
  return(r[i+1,])
}

## @knitr replacement
`start<-` <- function(x, ...) UseMethod("start<-")
`start<-.rw` <- function(object, value){ 
  object$origin <- value
  return(object)
}
set.seed(6)
walk <- rw(20)
start(walk) = c(5, 7)
summarize.rw(walk)
plot(walk,legend="topright")



######################################## S4 #################################



### 4.4.2 S4 approach

## @knitr s4
library(methods)
setClass("rw",representation(steps = "numeric" ,origin = "numeric") )

walk <- new("rw", steps=10, origin = c(0,0))


## @knitr s4methods
# generic method
setGeneric("print", function(object, ...) {
  standardGeneric("print")
})
setGeneric("plot", function(object, ...) {
  standardGeneric("plot")
})
setGeneric("summarize", function(object, ...) {
  standardGeneric("summarize")
})
setGeneric("path", function(object, ...) {
  standardGeneric("path")
})
# class-specific method
print.rw <- function(object) 
  return(random_walk(object@steps,plot=F,out="last",origin=object@origin))
path.rw <- function(object) 
  return(random_walk(object@steps,plot=F,out="path",origin=object@origin))
summarize.rw <- function(object) 
  return(with(object,cat("Random walk with ", object@steps, 
                          " steps and origin (", object@origin[1],",",object@origin[2],").\n",
                          sep = "")))
setMethod(print, signature = c("rw"), definition = print.rw)
setMethod(path, signature = c("rw"), definition = path.rw)
setMethod(summarize, signature = c("rw"), definition = summarize.rw)
setGeneric("plot")
setMethod("plot",c("rw"), function(object){
  random_walk(object@steps,plot=T,out="",origin=object@origin)
})

summarize(walk)
print(walk)
path(walk)

walk@origin <- c(5,4)
walk
plot(walk)

######################################## RC #################################



## @knitr

### 4.4.3 Reference classes

## @knitr refclass
rw <- setRefClass("rw", 
                          fields = list(steps="numeric",origin="numeric") ,
                          
                          methods = list(
                            initialize = function(steps = 100, origin = c(0,0), ...){
                              require(fields)
                              steps <<- steps # field assignment requires using <<-
                              origin <<- origin
                              callSuper(...) # calls initializer of base class (envRefClass)
                            },
                            print = function(rw) 
                              return(random_walk(steps,plot=F,out="last",origin=origin))
                          )

)


## @knitr refMethod
rw$methods(list(
  print = function(rw) 
    return(random_walk(rw$steps,plot=F,out="last",origin=rw$origin))
   )
)
walk <- rw$new()
print(walk)

## @knitr refUse, fig.width=4, eval=FALSE
master <- tsSimClass$new(1:100, 10)
master
tsSimClass$help('calcMats')
devs <- master$simulate()
plot(master$times, devs, type = 'l')
mycopy <- master
myDeepCopy <- master$copy()
master$changeTimes(seq(0,1, length = 100))
mycopy$times[1:5]
myDeepCopy$times[1:5]


## @knitr refAccess, eval=FALSE
master$field('times')[1:5]
# the next line is dangerous in this case, since
# currentU will no longer be accurate
master$field('times', 1:10) 



