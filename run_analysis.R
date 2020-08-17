library(reshape2)
library(knitr)
filename<-"getdata_projectfiles_UCI HAR Dataset"

##Download and unzip
if(!file.exists(filename)){
  url<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(url,filename)
}
if(!file.exists("UCI HAR Dataset")){
  unzip(filename)
}


activityLabels<-read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2]<-as.character(activityLabels[,2])
features<-read.table("UCI HAR Dataset/features.txt")
features[,2]<-as.character(features[,2])

##Extract data
features_need<-grep(".*mean.*|.*std.*",features[,2])
features_need.names<-features[features_need,2]
features_need.names = gsub('-mean', 'Mean', features_need.names)
features_need.names = gsub('-std', 'Std', features_need.names)
features_need.names <- gsub('[-()]', '', features_need.names)

##Get data
train <- read.table("UCI HAR Dataset/train/X_train.txt")[features_need]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[features_need]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

##Merge test and train
Data <- rbind(train, test)
colnames(Data) <- c("subject", "activity", features_need.names)

##Factor
Data$activity <- factor(Data$activity, levels = activityLabels[,1], labels = activityLabels[,2])
Data$subject <- as.factor(Data$subject)

Data.melted <- melt(Data, id = c("subject", "activity"))
Data.mean <- dcast(Data.melted, subject + activity ~ variable, mean)
##Get txt file
write.table(Data.mean, "tidy.txt", row.names = FALSE, quote = FALSE)


