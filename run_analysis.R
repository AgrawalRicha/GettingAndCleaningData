library(data.table)

## Download the data and unzip it.

url <-'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
if (!file.exists('./UCI HAR Dataset.zip')){
  download.file(url,'./UCI HAR Dataset.zip', mode = 'wb')
  unzip("UCI HAR Dataset.zip", exdir = ".")
}

## Read data and merge it into a single data frame

features <- read.csv('./UCI HAR Dataset/features.txt', header = FALSE, sep = ' ')
features <- as.character(features[,2])

data.train.feat <- read.table('./UCI HAR Dataset/train/X_train.txt')
data.train.activity <- read.csv('./UCI HAR Dataset/train/y_train.txt', header = FALSE, sep = ' ')
data.train.subject <- read.csv('./UCI HAR Dataset/train/subject_train.txt',header = FALSE, sep = ' ')

data.train <-  data.frame(data.train.subject, data.train.activity, data.train.feat)
names(data.train) <- c(c('subject', 'activity'), features)

data.test.feat <- read.table('./UCI HAR Dataset/test/X_test.txt')
data.test.activity <- read.csv('./UCI HAR Dataset/test/y_test.txt', header = FALSE, sep = ' ')
data.test.subject <- read.csv('./UCI HAR Dataset/test/subject_test.txt', header = FALSE, sep = ' ')

data.test <-  data.frame(data.test.subject, data.test.activity, data.test.feat)
names(data.test) <- c(c('subject', 'activity'), features)

data.merged <- rbind(data.train, data.test)

##Extract only the measurements on the mean and standard deviation for each measurement.

select_mean_std<-grep("mean|std",features)
data.subset<-data.merged[,c(1,2,select_mean_std +2)]

##Use descriptive activity names to name the activities in the data set
activity.names<-read.table('./UCI HAR Dataset/activity_labels.txt', header = FALSE)
activity.names<-as.character(activity.names[,2])
data.subset$activity<-activity.names[data.subset$activity]

##Appropriately label the data set with descriptive names
data.name<-names(data.subset)
data.name<-gsub("[(][)]","",data.name)

data.name<-gsub("Acc", "Accelerometer", data.name)
data.name<-gsub("Gyro", "Gyroscope", data.name)
data.name<-gsub("Mag", "Magnitude", data.name)

data.name<-gsub("^t", "Time_Domain_", data.name)
data.name<-gsub("^f", "Frequency_Domain_", data.name)

data.name<-gsub("-mean-", "_Mean_", data.name)
data.name<-gsub("-std-", "_Standard_Deviation_", data.name)
data.name<-gsub("-", "_", data.name)

names(data.subset) <- data.name

##Create an independent tidy data set with the average of each variable for each activity and each subject

data.tidy <- aggregate(data.subset[,3:81], by = list(activity = data.subset$activity, subject = data.subset$subject),FUN = mean)
write.table(x = data.tidy, file = "data_tidy.txt", row.names = FALSE)



