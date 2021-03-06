
model_bias <- function(x,y){
	t <- 0
	for(i in 1:length(x)){
		t <- ((x[i] - y[i]))/length(x) + t
	}
	t
}

mean_square_error <- function(x,y){
	t <- 0
	for(i in 1:length(x)){
		t <- ((x[i]-y[i])^2)/length(x) + t
	}
	t
}

mean_absolute_error <- function(x,y){
	t <- 0
	for(i in 1:length(x)){
		t <- abs((x[i]-y[i]))/length(x) + t
	}
	t
}

aic <- function(p,mle){
	return (2*p - 2*log(abs(mle)))
}

psse_times <- function(model, data, model_params){
	t <- 0
	mvf_data <- get(paste(model,"MVF",sep="_"))(model_params, data)
	for(i in 1:length(data$FT)){
		t <- (data$FT[i] - mvf_data$Time[i])^2 + t
	}
	t
}

psse_failures <- function(d,model_params){
	# input raw data IF vector
	# input model params
	# 
	# n <- length(d$FT)
 #  r <-data.frame()
 #  cumulr <-data.frame()
 #  for(i in 1:n){
 #    r[i,1] <- i
 #    r[i,2] <- 1/(param$Phi*(param$N0-(i-1)))
 #    cumulr[i,1] <- i
 #    cumulr[i,2] <- 0    
 #    for(j in 1:length(r[[1]])){      
 #      cumulr[i,2] <- cumulr[i,2]+r[j,2]
 #    }
 #  }

 #  g <- data.frame(cumulr[2],cumulr[1])
 #  names(g) <- c("Time","Failure")
 #  print(g)
 #  g

 	n <- length(data$FT)
 	r <- data.frame()
 	cumulr <- data.frame()
 	cumulr[i,1] <- 0
 	cumulr[i,2] <- 0
 	for(i in 1:n){
 		next_delta <- data$IF[i]
 		r[i,1] <- i
 		for(j in 1:next_delta){

 		}
 	}
}