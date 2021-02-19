# Processes output info of frames from deep meerkat and define it as events
# rm(list=ls())

Process_framecsv <- function(FileName){
#processes raw data from meerkat, outputs long and short format of events
  
data <- read.csv(paste("../MeerkatOutput/",FileName,"/annotations.csv", sep=""))

data$FileName <- FileName #Add file name column

#defining events:
data$diff <- c(0,diff(data$Frame))

#group stuff that is lower than 20 diff frames sequentially,remove 2 frames or less
counter <- 1 #counter for event num
EventNumCounter <- 0
EventVect <- rep(NA,nrow(data))
for(i in 1:nrow(data)){
  #browser()
  if(data$diff[i]>20){
    if(EventNumCounter <3){
      #if previous 'event' has 2 or less frames
      EventVect[(i-EventNumCounter):(i-1)] <- NA
      counter <- counter-1}
    #larger than 20, new event
    counter <- counter+1
    EventVect[i] <- counter
    EventNumCounter <- 1 #counts number of frames in the event
  }else{
    #smaller than 20, continue same event
    EventVect[i] <- counter
    EventNumCounter <- EventNumCounter +1 
  }
}

data$Event <- EventVect
write.csv(data, file=paste("../MeerkatOutput/",FileName,"/FramesLong.csv", sep=""))

###Part 2: Get short format:###

#convert time to decimals:
data$Time.dec <-sapply(strsplit(data$Clock, ":"), 
                       function(x){
                         x <- as.numeric(x)
                         x[1]*60 + x[2]+x[3]/60
                       })

#convert long to short format:
UnqEvents <- na.omit(unique(data$Event))
DataShort <- data.frame(matrix(data=NA, nrow=length(UnqEvents), ncol=4))
names(DataShort) <-c("Event","MeanTime","StartFrame", "EndFrame")

for(i in 1:length(UnqEvents)){
  sub <- subset(data,data$Event==UnqEvents[i])
  DataShort[i,] <- c(UnqEvents[i], mean(sub$Time.dec), sub[1,names(sub)=="Frame"],sub[nrow(sub),names(sub)=="Frame"])
}

write.csv(DataShort, file=paste("../MeerkatOutput/",FileName,"/FramesShort.csv", sep=""))
  
}


#Process file for testing:
# FileName <- "VT0115_S1_VP7_20190607"
# Process_framecsv(FileName)
