library(plyr)


##Merge the training and test sets to create one data set##



##download the file and put it in the data folder
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip")

##unzip the folder
unzip(zipfile="./data/Dataset.zip",exdir="./data")

##find out what files exist in the folder
UCI_HARdataset <- file.path("./data" , "UCI HAR Dataset")
files<-list.files(UCI_HARdataset, recursive=TRUE)

##read data 
dataActivityTest  <- read.table(file.path(UCI_HARdataset, "test" , "Y_test.txt" ),header = FALSE)
dataActivityTrain <- read.table(file.path(UCI_HARdataset, "train", "Y_train.txt"),header = FALSE)

dataSubjectTest  <- read.table(file.path(UCI_HARdataset, "test" , "subject_test.txt"),header = FALSE)
dataSubjectTrain <- read.table(file.path(UCI_HARdataset, "train", "subject_train.txt"),header = FALSE)

dataFeaturesTest  <- read.table(file.path(UCI_HARdataset, "test" , "X_test.txt" ),header = FALSE)
dataFeaturesTrain <- read.table(file.path(UCI_HARdataset, "train", "X_train.txt"),header = FALSE)

#combine the data tables
dataSubject<- rbind(dataSubjectTest, dataSubjectTrain)
dataActivity<- rbind(dataActivityTest, dataActivityTrain)
dataFeatures<- rbind(dataFeaturesTest, dataFeaturesTrain)

#titles for variables
names(dataSubject)<-c("Subject")
names(dataActivity)<-c("Activity")
dataFeaturesNames<-read.table(file.path(UCI_HARdataset, "features.txt"), head=FALSE)
names(dataFeatures)<- dataFeaturesNames$V2

#combine the columns
dataCombined<-cbind(dataSubject, dataActivity)
AllData<-cbind(dataFeatures,dataCombined)



##Extract only the measurements on the mean and standard deviation for each measurement##

subdataFeaturesName<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]
selectedNames<-c(as.character(subdataFeaturesName), "Subject", "Activity")
AllData<-subset(AllData, select=selectedNames)


##Use descriptive activity names to name the activities in the data set.##

activityLabels <- read.table(file.path(UCI_HARdataset, "activity_labels.txt"),header = FALSE)
AllData$Activity <- as.character(AllData$Activity)
for (i in 1:6){
  AllData$Activity[AllData$Activity == i] <- as.character(activityLabels[i,2])
}

##Label the data set with descriptive variable names. ##

names(AllData)<-gsub("^t", "Time", names(AllData))
names(AllData)<-gsub("Acc", "Accelerometer", names(AllData))
names(AllData)<-gsub("Gyro", "Gyroscope", names(AllData))
names(AllData)<-gsub("Mag", "Magnitude", names(AllData))
names(AllData)<-gsub("BodyBody", "Body", names(AllData))
names(AllData)<-gsub("^f", "Frequency", names(AllData))


##Create a second, independent tidy data set with the average of each variable for each activity and each subject.


SecondData<- aggregate(. ~Subject + Activity, AllData, mean)
SecondData<-SecondData[order(SecondData$Subject, SecondData$Activity),]
write.table(SecondData, file=
              "tidydata.txt", row.name=FALSE)

