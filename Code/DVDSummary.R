rm(list=ls())

setwd("C:/Documents and Settings/Alex Chan/Documents/SparrowVis/Code/")
DVDinfo <- read.csv("../Data/DVDInfo.csv")
DVDSum<- read.csv("../Data/DVDSummary.csv")
ProvOverview <- read.csv("../Data/ProvisionOverview.csv") #overview of provision/ incubation

#Remove repeats from ProvOverview
UnqNum <- unique(ProvOverview$DVDNumber)
#preset output dataframe:
ProvOverViewShort <- data.frame(matrix(ncol=9, nrow=length(UnqNum)))
colnames(ProvOverViewShort) <- names(ProvOverview)

#for loop:
for(i in 1:length(UnqNum)){
  sub <- subset(ProvOverview, ProvOverview$DVDNumber==UnqNum[i])
  if(nrow(sub) > 1){
    if(nrow(sub)>2){
      #number of rows is more than 2
      print(paste("PANIK MORE THAN 2 AT DVD#",UnqNum[i]))
    }else{
      #number of row is 2, need to check if focal and partner is just flipped
      if(sum(as.character(sub[1,5:9])==as.character(sub[2,5:9]))==5){#check if all other columns are equal
        #all other columns are equal
        if(sum(c(sub[1,1], sub[1,2]))==sum(c(sub[2,1], sub[2,2]))){
          #all good, focal and partner switched
          ProvOverViewShort[i,] <- sub[1,]
          
        }else{
          #partner and focal doesnt match
          print(paste("FOCAL AND PARTNER DOESNT MATCH AT #DVD", UnqNum[i])) 
        }
      }else{
        #other columns are not equal
        print(paste("SCREAM COLUMNS NOT EQUAL AT DVD#",UnqNum[i]))
      }
    }
  }else{
    #number of rows is 1
    ProvOverViewShort[i,] <- sub[1,]
  }
}


#merging ProvOverview and DVDinfo
Provsub <- ProvOverViewShort[,-4] #remove age column, will overlap
DVDinfoNew <- merge(Provsub, DVDinfo, by="DVDNumber", all=T)
write.csv(DVDinfoNew, file="../Data/DVDinfo_Updated.csv")
# DVDinfoNew <- DVDinfoNew[-which(is.na(DVDinfoNew$DVDNumber)), ]



#quick test: for the rows that both have data, does DVDRef.x and DVDRef.y match?
noNAsub <- DVDinfoNew[-which(is.na(DVDinfoNew$DVDRef.x)),]
noNAsub$Boolean <- noNAsub$DVDRef.x==noNAsub$DVDRef.y
unique(noNAsub$Boolean) #only trues found, test passed

#testing if the situation is really what they mean
DVDinfoNew$TestSituation <- paste(DVDinfoNew$TypeOfCare, DVDinfoNew$Situation)
unique(DVDinfoNew$Test) #test passed


##Create type of data (incubation6/12, provision 7/11):
DVDinfoNew$Type <- paste(DVDinfoNew$TypeOfCare,DVDinfoNew$Age)
unique(DVDinfoNew$Type)



#####Extracting file names from hard disk#####
##making list by year subset
Years <- na.omit(unique(DVDinfoNew$Year))
Yearsublist <- vector(mode="list", length=length(Years)) #preallocate list for year subsets

for(i in 1:length(Years)){
  Yearsublist[[i]] <- subset(DVDinfoNew, DVDinfoNew$Year==Years[i])
}


#reading in all the files available in hard disk, compare with database
setwd("D:/Provision Videos/") #Set working directory to hard drive
rm(list=ls())
list.files()

