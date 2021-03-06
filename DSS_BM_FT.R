#Vector of failure times data
# x <- c(3, 33, 146, 227, 342, 351, 353, 444, 556, 571, 709, 759, 836, 860, 968, 1056, 1726, 1846, 1872, 1986, 2311, 2366, 2608, 2676, 3098, 3278, 3288, 4434, 5034, 5049, 5085, 5089, 5089, 5097, 5324, 5389, 5565, 5623, 6080, 6380, 6477, 6740, 7192, 7447, 7644, 7837, 7843, 7922, 8738, 10089, 10237, 10258, 10491, 10625, 10982, 11175, 11411, 11442, 11811, 12559, 12559, 12791, 13121, 13486, 14708, 15251, 15261, 15277, 15806, 16185, 16229, 16358, 17168, 17458, 17758, 18287, 18568, 18728, 19556, 20567, 21012, 21308, 23063, 24127, 25910, 26770, 27753, 28460, 28493, 29361, 30085, 32408, 35338, 36799, 37642, 37654, 37915, 39715, 40580, 42015, 42045, 42188, 42296, 42296, 45406, 46653, 47596, 48296, 49171, 49416, 50145, 52042, 52489, 52875, 53321, 53443, 54433, 55381, 56463, 56485, 56560, 57042, 62551, 62651, 62661, 63732, 64103, 64893, 71043, 74364, 75409,76057, 81542, 82702, 84566, 88682)

#Define n, tn and sumT
DSS_BM_MLE <- function(x){

n <- length(x)
tn <- x[n]
sumT <- sum(x)

#Define MLE of parameter 'b'
MLEeq<-function(b){
  (2/b)-((b*tn^2)/(exp(b*tn)-1-b*tn))-((sum(x))/(n)) 
}

#Step-1: Determine initial parameter estimate for parameter 'b'

b0 <- n/sumT

#Step-2: Bracket root

i <- 0 
maxIterations <- 10
leftEndPoint <- b0/2
leftEndPointMLE <- MLEeq(leftEndPoint)
rightEndPoint <- 2*b0
rightEndPointMLE <- MLEeq(rightEndPoint)

while(leftEndPointMLE*rightEndPointMLE > 0 & i <= maxIterations){
  print('In Step 2 while loop of DSS_BM_FT.R')
  leftEndPoint <- leftEndPoint/2
  leftEndPointMLE <- MLEeq(leftEndPoint)
  rightEndPoint <- 2*rightEndPoint
  rightEndPointMLE <- MLEeq(rightEndPoint)
  i <- i+1	
}

#Step-3: Invoke uniroot or report non convergence to calling environment

if(leftEndPointMLE*rightEndPointMLE > 0 ){
  return('nonconvergence')
} else {
   maxiter <<- 20
  soln <- function(maxiter){
    sol <- tryCatch(
      uniroot(MLEeq, c(leftEndPoint,rightEndPoint), maxiter=maxiter, tol=1e-10, extendInt="yes")$root,
      warning = function(w){
      #print(f.lower)
        if(length(grep("_NOT_ converged",w[1]))>0){
          maxiter <<- maxiter+1 
          print(paste("recursive", maxiter,sep='_'))
          soln(maxiter)
        }
      },
      error = function(e){
        print(e)
        #return(e)
      })
    sol
  }
  bMLE <- soln(maxiter)
  if(bMLE < 0){
    return('nonconvergence')
  }
  #bMLE <- uniroot(MLEeq,lower=leftEndPoint,upper=rightEndPoint, tol = 1e-10)$root
  #bMLE <- uniroot(MLEeq,c(leftEndPoint,rightEndPoint))$root
}

print(bMLE)
#Step-4
#MLE of parameter 'a'
aMLE <- n/(1-exp(-bMLE*tn)*(1+bMLE*tn))
print(aMLE)

params <- data.frame("DSS_aMLE"=aMLE,"DSS_bMLE"=bMLE)
params

}

#Mean Value function
DSS_MVF <- function(param,d){
  #param$aMLE <- 100
  n <- length(d$FT)
  r <- data.frame()
  print(param)
  #t_index <- seq(0,9000,1)
  # param$aMLE <- 142.8809
  # param$bMLE <- 3.420379e-05
  t_index <- seq(d$FT[1],d$FT[n],(d$FT[n]-d$FT[1])/100)
  for(i in 1:length(t_index)){
    r[i,1] <- t_index[i]
    r[i,2] <- param$DSS_aMLE*(1-exp(-1*t_index[i]*param$DSS_bMLE)*(1+param$DSS_bMLE*t_index[i]))
    r[i,3] <- "DSS"
  }
  r <- data.frame(r[1],r[2],r[3])
  names(r) <- c("Time","Failure","Model")
  r
}

# log-Likelihood
DSS_lnL <- function(x,params){ # ----> params should be the option to generalize
    #lnL <- -aMLE*(1-(1+bMLE*tn)*exp(-bMLE*tn))+n*log(aMLE)+2*n*log(bMLE)+sum(log(x))-bMLE*sum(x)
    n <- length(x)
    tn <- x[n]
    firstSumTerm=0
    secondSumTerm = 0

    for(i in 1:n){
        firstSumTerm = firstSumTerm + log(x[i])
        secondSumTerm = secondSumTerm + (-params$DSS_bMLE*x[i])
      }
      lnL <- -params$DSS_aMLE*(1-(1+params$DSS_bMLE*tn)*exp(-bMLE*tn))+ n*(log(params$DSS_aMLE)) + 2*n*log(params$DSS_bMLE) +  firstSumTerm + secondSumTerm
      lnL
  }


DSS_MTTF <- function(params,d){
  n <- length(d$FT)
  r <-data.frame()
  cumulr <-data.frame()
  for(i in 1:n){
    r[i,1] <- i
    r[i,2] <- 1/((params$DSS_aMLE)*(params$DSS_bMLE^2)*d$FT[i]*(exp(-params$DSS_bMLE*(i))))
    r[i,3] <- "DSS"
    }
  r <- data.frame(r[1],r[2],r[3])
  names(r) <- c("Failure_Number","MTTF","Model")
  r

}


DSS_FI <- function(params,d){
  n <- length(d$FT)
  r <-data.frame()
  cumulr <-data.frame()
  for(i in 1:n){
    r[i,1] <- d$FT[i]
    r[i,2] <- (params$DSS_aMLE)*(params$DSS_bMLE^2)*d$FT[i]*(exp(-params$DSS_bMLE*d$FT[i]))
    r[i,3] <- "DSS"
    }
  r <- data.frame(r[1],r[2],r[3])
  names(r) <- c("Failure_Count","Failure_Rate","Model")
  r
}


DSS_R <- function(params,d){
  n <- length(d$FT)
  r <-data.frame()
  cumulr <-data.frame()
  for(i in 1:n){
    r[i,1] <- d$FT[i]
    r[i,2] <- exp(-(params$DSS_aMLE*d$FT[i]))
    r[i,3] <- "DSS"
  }
  r <- data.frame(r[1],r[2],r[3])
  names(r) <- c("Time","Reliability","Model")
  r
}

# DSS_R_growth <- function(){

# }
#MVF <- aMLE*(1-(1+bMLE*x)*exp(-bMLE*x))

DSS_Faults_Remain <- function(){
  # a(1+ bt)e^(-bt)
}

DSS_MVF_cont <- function(param,t){
  return(param$DSS_aMLE*(1-exp(-1*t*param$DSS_bMLE)*(1+param$DSS_bMLE*t)))
}

DSS_R_delta <- function(params,cur_time,delta){
  return(exp(-(DSS_MVF_cont(params,(cur_time+delta)) - DSS_MVF_cont(params,cur_time))))
}

DSS_R_MLE_root <- function(params,cur_time,delta, reliability){
  root_equation <- reliability - exp(params$DSS_aMLE*(1-exp(-params$DSS_bMLE*cur_time)) -params$DSS_aMLE*(1-exp(-params$DSS_bMLE*(cur_time+delta))))
  return(root_equation)
}

maxiter <- 1000
DSS_Target_T <- function(params,cur_time,delta, reliability){

  f <- function(t){
    return(DSS_R_MLE_root(params,t,delta, reliability))
  }

  current_rel <- DSS_R_delta(params,cur_time,delta)
  if(current_rel < reliability){
      sol <- tryCatch(
        uniroot(f, c(cur_time,cur_time + 50),extendInt="yes", maxiter=maxiter, tol=1e-10)$root,
        warning = function(w){
        #print(f.lower)
          if(length(grep("_NOT_ converged",w[1]))>0){
            maxiter <<- maxiter+10
            print(paste("recursive", maxiter,sep='_'))
            DSS_Target_T(a,b,cur_time,delta, reliability)
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

DSS_R_growth <- function(params,cur_time,delta, reliability){  
  
  r <-data.frame()
  tt_index <- seq(0,cur_time,cur_time/1000)
    for(i in 1:length(tt_index)){   
      r[i,1] <- tt_index[i]
      temp <- DSS_R_delta(params,tt_index[i],delta)
      #print(typeof(temp))
      if(typeof(temp) != typeof("character")){
        r[i,2] <- temp
        r[i,3] <- "DSS"
      }
      else{
        r[i,2] <- "NA"
        r[i,3] <- "DSS"
      }     
    }
    g <- data.frame(r[1],r[2],r[3])
    names(g) <- c("Time","Reliability_Growth","Model")
    #print(g)
    g
      
}