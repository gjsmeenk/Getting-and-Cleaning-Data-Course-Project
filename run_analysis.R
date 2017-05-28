## if directory "data" not exists, create a directory "data":
if(!file.exists("./data")){dir.create("./data")}

## if the dataset not exists, download and unzip the data
if(!file.exists("./data/UCI HAR Dataset")){
        ## downloading dataset
        library(curl)
        fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        curl_download(fileUrl, destfile = "./data/Dataset.zip",quiet=TRUE, mode="wb")

        ## unzipping the downloaded file
        zipF <- "./data/Dataset.zip"
        outDir <-"./data"
        unzip(zipF,exdir=outDir)
        }

## reading variable names, 2nd column (V2) contains variable names
variables <- read.table("./data/UCI HAR Dataset/features.txt")
variables_unique <- make.names(variables$V2, unique = TRUE)
## reading variable names, 2nd column (V2) contains activity names
activityLabels <- read.table("./data/UCI HAR Dataset/activity_labels.txt")
colnames(activityLabels) <- c("id", "activity")

## reading testdata
testData <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
colnames(testData) <- variables_unique
## extract variables on mean and standar deviation (std)
## this means also excluding meanFreq!!
##x <- (grepl("mean",names(testData)) | grepl("std",names(testData))) & (!grepl("Freq",names(testData)))
##testData <- testData[,x]

## reading test-labels containing the activity and adding this as a column to the testData
testLabels <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
testData$activity_id <- testLabels$V1

## reading subjects who performed the activity and adding this as a column to the testData
testSubjects <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")
testData$subject <- testSubjects$V1

## reading training data
trainData <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
colnames(trainData) <- variables_unique
## extract variables on mean and standar deviation (std)
## this means also excluding meanFreq!!
##x <- (grepl("mean",names(trainData)) | grepl("std",names(trainData))) & (!grepl("Freq",names(trainData)))
##trainData <- trainData[,x]

## reading test-labels containing the activity and adding this as a column to the testData
trainLabels <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
trainData$activity_id <- trainLabels$V1
## reading subjects who performed the activity and adding this as a column to the testData
trainSubjects <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")
trainData$subject <- trainSubjects$V1

## combine testdata and training data
totalData <- rbind(testData,trainData)

##adding the labels for the activity numbers
totalData <- merge(totalData,activityLabels,by.x = "activity_id", by.y = "id")

##rearranging columns, renaming  and selecting only mean and std (package dplyr is needed)
## this means also excluding meanFreq!!
library(dplyr)
totalData <- select(totalData, subject, activity, contains("mean"), contains("std"), -contains("Freq"), -activity_id)
## sorting data by subject and activity
totalData <- arrange(totalData, subject, activity)

## creating dataset with average of each variable for each activity and each subject
means <- group_by(totalData, subject, activity)
means <- summarize_each(means, funs(mean))
write.table(means, "./data/means.txt", row.names = FALSE)