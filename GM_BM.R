#x <- c(3, 33, 146, 227, 342, 351, 353, 444,556, 571, 709, 759, 836, 860, 968,1056, 1726, 1846, 1872, 1986, 2311,2366, 2608, 2676, 3098, 3278, 3288,4434, 5034, 5049, 5085, 5089, 5089,5097, 5324, 5389, 5565, 5623, 6080,6380, 6477, 6740, 7192, 7447, 7644,7837, 7843, 7922, 8738, 10089, 10237,10258, 10491, 10625, 10982, 11175,11411, 11442, 11811, 12559, 12559,12791, 13121, 13486, 14708, 15251,15261, 15277, 15806, 16185, 16229,16358, 17168, 17458, 17758, 18287,18568, 18728, 19556, 20567, 21012,21308, 23063, 24127, 25910, 26770,27753, 28460, 28493, 29361, 30085,32408, 35338, 36799, 37642, 37654,37915, 39715, 40580, 42015, 42045,42188, 42296, 42296, 45406, 46653,47596, 48296, 49171, 49416, 50145,52042, 52489, 52875, 53321, 53443,54433, 55381, 56463, 56485, 56560, 57042, 62551, 62651, 62661, 63732,64103, 64893, 71043, 74364, 75409,76057, 81542, 82702, 84566, 88682)




GM_BM_MLE <- function(interFail){
n <-length(interFail)


MLEeq<-function(phi){
  NrTerm  <- 0
  DrTerm  <- 0
  
  for(i in 1:n){
    NrTerm =NrTerm+(i*(phi^i)*interFail[i])
    DrTerm = DrTerm +((phi^i)*interFail[i])
  }
  phi_MLE <- (NrTerm/DrTerm)-((n+1)/2)
  return(phi_MLE)
}


#Step-1: Determine initial parameter estimate for parameter 'b0'

#b0 <- n/sum(interFail)
#b0 <- n
b0 <- 1.0

#Step-2: Bracket root

i <- 0 
maxIterations <- 200
leftEndPoint <- b0/2
leftEndPointMLE <- MLEeq(leftEndPoint)
rightEndPoint <- 1.2*b0
rightEndPointMLE <- MLEeq(rightEndPoint)

while(leftEndPointMLE*rightEndPointMLE > 0 & i <= maxIterations){
  #print('In Step 2 while loop of GM_BM.R')
  leftEndPoint <- leftEndPoint/2
  leftEndPointMLE <- MLEeq(leftEndPoint)
  rightEndPoint <- 1.1*rightEndPoint
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
  phiMLE <- soln(maxiter)

  if(phiMLE < 0){
    return('nonconvergence')
  }



  #phiMLE <- uniroot(MLEeq,lower=leftEndPoint,upper=rightEndPoint, extendInt="yes", tol = 1e-10)$root
}
#print(phiMLE)

#Step-4
#MLE of parameter 'D'
DrTerm = 0
for(i in 1:n){
  DrTerm = DrTerm +((phiMLE^i)*interFail[i])
}
D_MLE <- (phiMLE*n)/DrTerm

#print(D_MLE)
params <- data.frame("GM_D0"=D_MLE,"GM_Phi"=phiMLE)
params
}

# GM_MVF <- function(param,d){
#   n <- length(d$FT)
#   r <- data.frame()
#   t_index <- seq(d$FT[1],d$FT[n],(d$FT[n]-d$FT[1])/100)
#   for(i in 1:length(t_index)){
#     r[i,1] <- t_index[i]
#     r[i,2] <- param$D0*(1-exp(-1*t_index[i]*param$Phi))
#   }
#   r <- data.frame(r[1],r[2])
#   names(r) <- c("Time","Failure")
#   r
# } 



GM_MVF <- function(param,d){
  n <- length(d$FT)
  r <-data.frame()
  cumulr <-data.frame()
  for(i in 1:n){
    r[i,1] <- i
    r[i,2] <- 1/(param$GM_D0*(param$GM_Phi)^i)
    cumulr[i,1] <- i
    cumulr[i,2] <- 0
    cumulr[i,3] <- "GM"
    for(j in 1:length(r[[1]])){
      
      cumulr[i,2] <- cumulr[i,2]+r[j,2]

    }

  }
  g <- data.frame(cumulr[2],cumulr[1],cumulr[3])
  names(g) <- c("Time","Failure","Model")
  g
  
}

GM_MTTF <- function(param,d){
  n <- length(d$FT)
  r <-data.frame()
  cumulr <-data.frame()
  for(i in 1:n){
    r[i,1] <- i
    r[i,2] <- 1/(param$GM_D0*(param$GM_Phi)^i)
    r[i,3] <- "GM"
    }
  r <- data.frame(r[1],r[2],r[3])
  names(r) <- c("Failure_Number","MTTF","Model")
  r  
}

GM_FI <- function(param,d){
  n <- length(d$FT)
  r <-data.frame()
  cumulr <-data.frame()
  for(i in 1:n){
    r[i,1] <- d$FT[i]
    r[i,2] <- (param$GM_D0*(param$GM_Phi^i))
    r[i,3] <- "GM"
    }
  r <- data.frame(r[1],r[2],r[3])
  names(r) <- c("Failure_Count","Failure_Rate","Model")
  print(r)
  r  
}

GM_R <- function(param,d){
  n <- length(d$FT)
  r <-data.frame()
  cumulr <-data.frame()
  for(i in 1:n){
    r[i,1] <- d$FT[i]
    r[i,2] <- exp((-1*param$GM_D0*(param$GM_Phi^i)*d$FT[i]))
    r[i,3] <- "GM"
  }
  r <- data.frame(r[1],r[2],r[3])
  names(r) <- c("Time","Reliability","Model")
  print(r)
  r
  
}

GM_lnL  <- function(){
  
}


GM_MVF_cont <- function(params,t){
  return( (-1/log(params$GM_Phi))*log(1+params$GM_D0*(-log(params$GM_Phi)*exp(-log(params$GM_Phi)))*t))
  #return(log(params$GM_D0*(1-exp(-params$JM_Phi*t)))
}

GM_R_delta <- function(params,cur_time,delta){
  return(exp(-(GM_MVF_cont(params,(cur_time+delta)) -GM_MVF_cont(params,cur_time))))
}

GM_R_MLE_root <- function(params,cur_time,delta, reliability){
  root_equation <- reliability - GM_R_delta(params,cur_time,delta)
  return(root_equation)
}

maxiter <- 1000
GM_Target_T <- function(params,cur_time,delta, reliability){

  f <- function(t){
    return(GM_R_MLE_root(params,t,delta, reliability))
  }

  current_rel <- GM_R_delta(params,cur_time,delta)
  if(current_rel < reliability){
      sol <- tryCatch(
        uniroot(f, c(cur_time,cur_time + 50),extendInt="yes", maxiter=maxiter, tol=1e-10)$root,
        warning = function(w){
        #print(f.lower)
          if(length(grep("_NOT_ converged",w[1]))>0){
            maxiter <<- maxiter+10
            print(paste("recursive", maxiter,sep='_'))
            GM_Target_T(a,b,cur_time,delta, reliability)
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

GM_R_growth <- function(params,cur_time,delta, reliability){  
  
  r <-data.frame()
  tt_index <- seq(0,cur_time,cur_time/1000)
    for(i in 1:length(tt_index)){   
      r[i,1] <- tt_index[i]
      temp <- GM_R_delta(params,tt_index[i],delta)
      #print(typeof(temp))
      if(typeof(temp) != typeof("character")){
        r[i,2] <- temp
        r[i,3] <- "GM"
      }
      else{
        r[i,2] <- "NA"
        r[i,3] <- "GM"
      }     
    }
    g <- data.frame(r[1],r[2],r[3])
    names(g) <- c("Time","Reliability_Growth","Model")
    #print(g)
    g
      
}
