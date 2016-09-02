## Download zip file and place in data folder
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip")

## Unzip Dataset.zip file
unzip(zipfile="./data/Dataset.zip",exdir="./data")

path_rf <- file.path("./data" , "UCI HAR Dataset")

## read in activity data
activitytestdata  <- read.table(file.path(path_rf, "test" , "Y_test.txt" ),header = FALSE)
activitytraindata <- read.table(file.path(path_rf, "train", "Y_train.txt"),header = FALSE)

## read in subject data
subjecttraindata <- read.table(file.path(path_rf, "train", "subject_train.txt"),header = FALSE)
subjecttestdata  <- read.table(file.path(path_rf, "test" , "subject_test.txt"),header = FALSE)

## read in features data
featurestestdata  <- read.table(file.path(path_rf, "test" , "X_test.txt" ),header = FALSE)
featurestraindata <- read.table(file.path(path_rf, "train", "X_train.txt"),header = FALSE)

## bind data
subjectdata <- rbind(subjecttraindata, subjecttestdata)
activitydata<- rbind(activitytraindata, activitytestdata)
featuresdata<- rbind(featurestraindata, featurestestdata)

names(subjectdata)<-c("subject")
names(activitydata)<- c("activity")
featuresnamesdata <- read.table(file.path(path_rf, "features.txt"),head=FALSE)
names(featuresdata)<- featuresnamesdata$V2

combinedata <- cbind(subjectdata, activitydata)
Data <- cbind(featuresdata, combinedata)

featuresnamessub<-featuresnamesdata$V2[grep("mean\\(\\)|std\\(\\)", featuresnamesdata$V2)]

selectednames<-c(as.character(featuresnamessub), "subject", "activity" )
Data<-subset(Data,select=selectednames)

activitylabels <- read.table(file.path(path_rf, "activity_labels.txt"), header = FALSE)
activitydata$activity <- factor(activitydata$activity, labels = activitylabels$V2)

names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))

## Create tidy dataset.
library(plyr);
Data2<-aggregate(. ~subject + activity, Data, mean)
Data2<-Data2[order(Data2$subject,Data2$activity),]
Data2$activity <- factor(Data2$activity, labels = activitylabels$V2)
Data2
write.table(Data2, file = "tidydata.txt",row.name=FALSE, quote = FALSE)