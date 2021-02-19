#Compares DVDinfo from database and files I have
rm(list=ls())

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
table(DVDinfoNew$Type)


#####2. Extracting file names from hard disk and compare#####
rm(list=ls())
library(stringi)
DVDinfoNew <- read.csv("../Data/DVDinfo_Updated.csv")

#reading in all the files available in hard disk, compare with database 
DiskFile <- read.csv("../Data/HardDiskFile.csv")
FileVect <- DiskFile$Files

#removing excel files:
FileVect <- FileVect[-which(endsWith(FileVect, "xls"))]
FileVect <- FileVect[-which(endsWith(FileVect, "xlsx"))]

#checking if videos exist using regex
Exist <- c(rep(NA,times=nrow(DVDinfoNew)))
NumFile <- c(rep(NA,times=nrow(DVDinfoNew)))

for(i in 1:nrow(DVDinfoNew)){
  VidCode <- DVDinfoNew$DVDNumber[i]
  #regular expression to search for file:
  FilesDetected <- sum(stri_detect_regex(FileVect, VidCode)) 
  if(FilesDetected>0){
    Exist[i] <- "Yes"
    NumFile[i] <-FilesDetected #number of that file
  }else{Exist[i] <- "No"}
  
}


DVDinfoNew$In_Hard_Disk <- Exist
DVDinfoNew$Number_of_files <- NumFile


##making list by year subset
DVDinfoNew$TypeDay <- paste(DVDinfoNew$TypeOfCare, DVDinfoNew$Age) #check type (prov/inc) and days after

Years <- na.omit(unique(DVDinfoNew$Year))
Yearsublist <- vector(mode="list", length=length(Years)) #preallocate list for year subsets

for(i in 1:length(Years)){
  Yearsublist[[i]] <- subset(DVDinfoNew, DVDinfoNew$Year==Years[i])
}

#summary:
names(Yearsublist)<- as.character(na.omit(unique(DVDinfoNew$Year)))
lapply(Yearsublist, function(x) {table(x$In_Hard_Disk)}) #summary table for each year
lapply(Yearsublist, function(x) {table(x$TypeDay)}) #summary of type of videos we have and day

#for 2015 +2016
Data2016 <- Yearsublist$`2016`
Prov2016 <- subset(Data2016,Data2016$TypeOfCare=="Prov")
table(Prov2016$In_Hard_Disk)
Inc2016 <- subset(Data2016,Data2016$TypeOfCare=="Inc")
table(Inc2016$In_Hard_Disk)

Data2015 <- Yearsublist$`2015`
Prov2015 <- subset(Data2015,Data2015$TypeOfCare=="Prov")
table(Prov2015$In_Hard_Disk)
Inc2016 <- subset(Data2015,Data2015$TypeOfCare=="Inc")
table(Inc2016$In_Hard_Disk)

#Check 2014:
Data2014 <- Yearsublist$`2014`
Prov2014 <- subset(Data2014,Data2014$TypeOfCare=="Prov")
table(Prov2014$In_Hard_Disk)
Inc2014 <- subset(Data2014,Data2014$TypeOfCare=="Inc")
table(Inc2014$In_Hard_Disk)
