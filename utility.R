isDataFR <- function(d){
	# input is names of input data file
	# d <- names(data)
	if("FT" %in% d){
		return(TRUE)
	}
	else if("IF" %in% d){
		return(TRUE)
	}
	else if("FN" %in% d){
		return(TRUE)
	}
	else{
		return(FALSE)
	}
}


isDataFC <- function(d){
	# input is names of input data file
	# d <- names(data)

	if("FC" %in% d){
		return(TRUE)
	}
	else if("CFC" %in% d){
		return(TRUE)
	}
	else{
		return(FALSE)
	}
}


isDataFormatted <- function(d){

	# Check if data is either FR or FC type
	# Also check if FR FN and FT/IF columns exist
	# Also check if FC FT and CFC/FC columns exist
	# returns FALSE if data is not formatted properly

	if(isModelFC(d)| isModelFR(d)){
		return(TRUE)
	}
	else{
		return(FALSE)
	}
}


isDataLegit <- function(){

	# Check if data is legit
	# If FR data check for monotonic increase in FT column
	# If FC data check for monotonic increase in CFC column
}


isDataSafe <- function(){

	# Hard coded 
	# Should be changed
	return(TRUE)
}


isModelFR <- function(){
	# 

}


isModelFC <- function(){

}


isModelBoth <- function(){

}


dataType <- function(d){
	# ---> d <- names(raw_data)
	if(!isDataSafe()){
		return(NULL)
	}
	if(isDataFC(d) && isDataFR(d)){
		return("FR|FC")
	}
	else if(isDataFR(d)) {
		return("FR")
	}
	else if(isDataFC(d)){
		return("FC")
	}
	else{
		return("Something went wrong")
	}
}


isIFCol <- function(d){
	if("IF" %in% d){
		return(TRUE)
	}
	else{
		return(FALSE)
	}
}


isFTCol <- function(d){
	if("FT" %in% d){
		return(TRUE)
	}
	else{
		return(FALSE)
	}
}


isFNCol <- function(){
	if("FN" %in% d){
		return(TRUE)
	}
	else{
		return(FALSE)
	}
}


isCFCCol <- function(d){
	if("CFC" %in% d){
		return(TRUE)
	}
	else{
		return(FALSE)
	}
}


isFCCol <- function(){
	if("FC" %in% d){
		return(TRUE)
	}
	else{
		return(FALSE)
	}
}


IF_to_FT <- function(interfailure) #interfailure to failure times
{
	failure_T <- c()
	failure_T[1] = interfailure[1] #initial value for failure time
	n = 2
	while(n<=length(interfailure)) # ----| While loops are dangerous please modify them with for loops
	{
	  failure_T[n] = interfailure[n] + failure_T[n-1]	  
	  n = n + 1
	}
	return(failure_T)#return interfailure times(interfailure)
}


FT_to_IF <- function(failure_T)
{
	interfailure <- c()
	interfailure[1] = failure_T[1] #initial value for failure time
	n = 2
	while(n<=length(failure_T)) # ---- | While loops are dangerous, please modify them with for-loop
	{
	  interfailure[n] = failure_T[n] - failure_T[n-1]	   
	   n = n+1
	}
	return(interfailure)#return failure times(failure_T)
}


CFC_to_FC <- function(x){
  fc <- c()
  x <- c(0,x)
  for(i in 1:(length(x)-1)){
     fc[i] <- x[i+1] - x[i]   
  }
  return(fc)
}


FC_to_CFC <- function(fc_vec){
	cfc <- c()
	# cfc[1] <- fc_vec[1] 
	#cfc[1] <- 0
	for(i in 1:length(fc_vec$FC)){
		cfc[i] <- 0
		for(j in 1:i){
			#print(j)
			cfc[i] <- cfc[i] + fc_vec$FC[j]
		}
	}
	cfc
}


FC_to_FT <- function(time_vec,num_count) #failure count to failure time
{
  failure_T <- c()
  time_vec<- c(0,time_vec)
  m <- 1
  for(j in 1:(length(time_vec)-1))
  {
    for(i in 1:num_count[j])
    {
      if(num_count[j]!=0)
      {
        failure_T[m] <- time_vec[j]+ ((i-0.5)*((time_vec[j+1]-time_vec[j])/num_count[j]))
        m <- m+1
      }
    }
  }
  return(failure_T)
}

isPlural <- function(){
	#-----> required to fix the plural forms
}

generate_dataFrame <- function(raw_data){
	#source("Data_Format.R")
	d <- names(raw_data)
	if(isDataSafe()){
		if(dataType(d)=="FR"){
			if(isIFCol(d)){
				IF <- raw_data$IF
				FT <- IF_to_FT(raw_data$IF)
				FN <- 1:length(raw_data$IF)
			}
			else if(isFTCol(d)){
				FT <- raw_data$FT
				IF <- FT_to_IF(raw_data$FT)
				FN <- 1:length(raw_data$FT)
			}
			else{
				# To be programmed
			}
			data_gen <- data.frame("FT"=FT,"IF"=IF,"FN"=FN)
		}
		else if(dataType(d)=="FC"){
			if(isCFCCol(d)){
				CFC <- raw_data$CFC
				FC <- CFC_to_FC(raw_data$CFC)
              	FT <- FC_to_FT(raw_data$T,FC) # Exception handling if T Column doesn't exist
            	IF <- FT_to_IF(failure_T = FT)
            	FN <- 1:length(FT)
			}
			else if(isFCCol(d)){
				# ----> for now CFC column is not generated.
				# ----? Should we need CFC column at all.
				# ----? Should we generate it for future.

				FC 	<- raw_data$FC
				CFC <- FC_to_CFC(raw_data$FC)
				FT 	<- FC_to_FT(raw_data$T,FC) # Exception handling if T Column doesn't exist
            	IF 	<- FT_to_IF(failure_T = FT)
            	FN 	<- 1:length(FT)
			}
			data_gen.FR <- data.frame("FT"=FT,"IF"=IF,"FN"=FN)
			data_gen.FC <- data.frame("FC"=FC, "CFC"=CFC)
			data_gen <- list(data_gen.FR,data_gen.FC)
			names(data_gen) <- c("FRate","FCount")
		}
	}
	data_gen
}