# require("Rmpfr")
require("utils")
# x is interfailure times
JM_BM_MLE<-function(interFail){
n <- length(interFail)

# Define MLE of parameter 'N0'

MLEeq<-function(N0){
leftTerm = 0
interFailSum = 0
rightTermDenominator = 0
for(i in 1:n){
	leftTerm =leftTerm+(1/(N0-(i-1)))
	interFailSum = interFailSum + interFail[i]
	rightTermDenominator = rightTermDenominator+((N0-(i-1))*interFail[i])
}
N0_MLE <- leftTerm-((n* interFailSum)/rightTermDenominator)
return(N0_MLE)
}

# Step-1: Determine initial parameter estimate for parameter 'b0'

# b0 <- n/sum(interFail)
b0 <- n
# print(paste("b): ",b0))
# Step-2: Bracket root

i <- 1
maxIterations <- 100000
leftEndPoint <- b0
leftEndPointMLE <- MLEeq(leftEndPoint)



rightEndPoint <- 2*b0
rightEndPointMLE <- MLEeq(rightEndPoint)


#------> ! print(paste("left:",leftEndPointMLE))
#------> ! print(paste("right:",rightEndPointMLE))

while(leftEndPointMLE*rightEndPointMLE > 0 & i <= maxIterations){
	#print('In Step 2 while loop of JM_BM.R')
	leftEndPoint <- leftEndPoint/2
	leftEndPointMLE <- MLEeq(leftEndPoint)
	rightEndPoint <- 2*rightEndPoint
	rightEndPointMLE <- MLEeq(rightEndPoint)
	i <- i+1	
}

# -----> ! print(c(leftEndPointMLE,rightEndPointMLE))
# -----> ! Step-3: Invoke uniroot or report non convergence to calling environment

if(leftEndPointMLE*rightEndPointMLE > 0 ){
	return('nonconvergence')
} else {



  maxiter <<- 20
  soln <- function(maxiter){
    sol <- tryCatch(
      uniroot(MLEeq, c(leftEndPoint,rightEndPoint), maxiter=maxiter, tol=1e-10)$root,
      warning = function(w){
        if(length(grep("_NOT_ converged",w[1]))>0){
          maxiter <<- maxiter+10
          print(paste("recursive", maxiter,sep='_'))
          soln(maxiter)
        }
      },
      error = function(e){
        print(e)
      })
    sol
  }
  N0_MLE <- soln(maxiter)

  if(N0_MLE < n){
    return("nonconvergence")
  }
	# ----> ! N0_MLE <- unirootR(MLEeq,interval=mpfr(c(leftEndPoint,rightEndPoint),120),tol=1e-20)$root
	# ----> ! N0_MLE <- uniroot(MLEeq,lower=leftEndPoint,upper=rightEndPoint, extendInt="yes",maxiter=10000, tol = 1e-24)$root
	# ----> ! N0_MLE <- unirootR(MLEeq,lower=mpfr(leftEndPoint,300),upper=mpfr(rightEndPoint,300), tol = 1e-40)$root
}
tmp_phi <- numeric(0)
for(i in 1:n-1){
	tmp_phi[i] <- (N0_MLE-(i-1))*interFail[i]
}
Phi <- n/sum(tmp_phi)

JM_params <-  data.frame("JM_N0"=N0_MLE,"JM_Phi"=Phi)
return(JM_params)
}

JM_MVF_efficient <- function(param,d){
  n <- length(d$FT)
  r <-data.frame()
  cumulr <-data.frame()
  for(i in 1:n){
    r[i,1] <- i
    r[i,2] <- 1/(param$JM_Phi*(param$JM_N0-(i-1)))
    cumulr[i,1] <- i
    cumulr[i,2] <- 0    
    for(j in 1:length(r[[1]])){
      cumulr[i,2] <- cumulr[i,2]+r[j,2]
    }
  }

  g <- data.frame(cumulr[2],cumulr[1])
  names(g) <- c("Time","Failure")
  print(g)
  g  
}

JM_MVF <- function(param,d){
  n <- length(d$FT)
  r <-data.frame()
  cumulr <-data.frame()
  cumulr[1,1] <- 0
  cumulr[1,2] <- 0
  for(i in 1:n){
    r[i,1] <- i
    r[i,2] <- 1/(param$JM_Phi*(param$JM_N0-(i-1)))
    cumulr[i,1] <- i
    cumulr[i,2] <- 0
    cumulr[i,3] <- "JM"
    for(j in 1:length(r[[1]])){      
        cumulr[i,2] <- cumulr[i,2]+r[j,2]      
      
    }
  }

  g <- data.frame("Time"=cumulr[2],"Failure"=cumulr[1],"Model"=cumulr[3]) # ----> naming doesn't work should find why
  names(g) <- c("Time","Failure","Model") # ----> I have to use this reduntantly because of above comment(reason)
  print(g)
  g  
}

JM_MTTF <- function(param,d){
  n <- length(d$FT)
  r <-data.frame()
  cumulr <-data.frame()
  for(i in 1:n){
    r[i,1] <- i
    r[i,2] <- 1/(param$JM_Phi*(param$JM_N0-(i-1)))
    r[i,3] <- "JM"
    }
  r <- data.frame(r[1],r[2],r[3])
  names(r) <- c("Failure_Number","MTTF","Model")
  r  
}

JM_FI <- function(param,d){
  n <- length(d$FT)
  r <-data.frame()
  cumulr <-data.frame()
  for(i in 1:n){
    r[i,1] <- d$FT[i]
    r[i,2] <- (param$JM_Phi*(param$JM_N0-(i-1)))
    r[i,3] <- "JM"
    }
  r <- data.frame(r[1],r[2],r[3])
  names(r) <- c("Failure_Count","Failure_Rate","Model")
  r  
}

JM_R <- function(param,d){
  n <- length(d$FT)
  r <-data.frame()
  cumulr <-data.frame()
  for(i in 1:n){
    r[i,1] <- d$FT[i]
    r[i,2] <- exp(-param$JM_Phi*(param$JM_N0-(n-1))*d$FT[i])
    r[i,3] <- "JM"
  }
  r <- data.frame(r[1],r[2],r[3])
  names(r) <- c("Time","Reliability","Model")
  r
}

JM_MVF_r <- function(param,d){
  n <- length(d$FT)
  r <- data.frame()
  t_index <- seq(d$FT[1],d$FT[n],(d$FT[n]-d$FT[1])/100)
  for(i in 1:length(t_index)){
    r[i,1] <- t_index[i]
    r[i,2] <- param$JM_N0*(1-exp(-1*t_index[i]*param$JM_Phi))
  }
  r <- data.frame(r[1],r[2])
  names(r) <- c("Time","Failure")
  r
}

# Maximum value of Log-likelihood

JM_lnL <- function(x,params){ # ----> params should be the option to generalize
    n <- length(x)          
    secondTerm=0
    thirdTerm = 0

    for(i in 1:n){
        secondTerm = secondTerm +log((params$JM_N0-(i-1)))
        thirdTerm = thirdTerm +((params$JM_N0-(i-1))*x[i])#x=interFail
      }
      lnL <- n*log(params$JM_Phi)+ secondTerm-(params$JM_Phi*thirdTerm)
      return(lnL)
  }
 
 #Faults Remaining
 
 JM_FaultsRemaining <- function(params,n){ # ----> params should be passed instead
  return(floor(params$JM_N0-n))
 }
 
 #Reliability

 JM_Reliability <- function(n,x,params){ # params should be passed instead
  Reliability <- numeric(0)
  Reliability <- exp(-params$Phi*(params$JM_N0-(i-1))*x[i])
  return(Reliability)
 }
 


JM_MVF_cont <- function(params,t){
  return(params$JM_N0*(1-exp(-params$JM_Phi*t)))
}

JM_R_delta <- function(params,cur_time,delta){
  return(exp(-(JM_MVF_cont(params,(cur_time+delta)) -JM_MVF_cont(params,cur_time))))
}

JM_R_MLE_root <- function(params,cur_time,delta, reliability){
  root_equation <- reliability - exp(params$JM_N0*(1-exp(-params$JM_Phi*cur_time)) - params$JM_N0*(1-exp(-params$JM_Phi*(cur_time+delta))))
  return(root_equation)
}

maxiter <- 1000
JM_Target_T <- function(params,cur_time,delta, reliability){

  f <- function(t){
    return(JM_R_MLE_root(params,t,delta, reliability))
  }

  current_rel <- JM_R_delta(params,cur_time,delta)
  if(current_rel < reliability){
      sol <- tryCatch(
        uniroot(f, c(cur_time,cur_time + 50),extendInt="yes", maxiter=maxiter, tol=1e-10)$root,
        warning = function(w){
        #print(f.lower)
          if(length(grep("_NOT_ converged",w[1]))>0){
            maxiter <<- maxiter+10
            print(paste("recursive", maxiter,sep='_'))
            JM_Target_T(a,b,cur_time,delta, reliability)
          }
        },
        error = function(e){
          print(e)
          #return(e)
        })
  }
  else {
    sol <- "Target reliability already achieved"
  }
    sol
  }

JM_R_growth <- function(params,cur_time,delta, reliability){  
  
  r <-data.frame()
  tt_index <- seq(0,cur_time,cur_time/1000)
    for(i in 1:length(tt_index)){   
      r[i,1] <- tt_index[i]
      temp <- JM_R_delta(params,tt_index[i],delta)
      #print(typeof(temp))
      if(typeof(temp) != typeof("character")){
        r[i,2] <- temp
        r[i,3] <- "JM"
      }
      else{
        r[i,2] <- "NA"
        r[i,3] <- "JM"
      }     
    }
    g <- data.frame(r[1],r[2],r[3])
    names(g) <- c("Time","Reliability_Growth","Model")
    #print(g)
    g
      
}

 #MTTF
 
 # JM_MTTF <- function(n,params){ # params should be passed instead
 #  MTTF=0
 #  for(i in 1:n){
 #    MTTF = MTTF +(1/(params$JM_Phi*(params$JM_N0-(n+(i-1)))))
 #  }
 #  return(MTTF)
 # }