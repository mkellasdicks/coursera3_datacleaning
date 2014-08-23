###################
##
##  Description
##
##      Script for Coursera Course on Data Cleaning (Course 3)
##      Peer Assignment
##
##  Requirements:
##


# Here are the data for the project: 
#
# https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
# 
# You should create one R script called run_analysis.R that does the following. 
# 
# 1.    Merges the training and the test sets to create one data set.
# 2.	Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3.	Uses descriptive activity names to name the activities in the data set
# 4.	Appropriately labels the data set with descriptive variable names. 
# 5.	Creates a second, independent tidy data set with the average of each variable for each activity and each subject.
# 
##

############################################################################################
##
##  Assumptions
##      project working directory set
##      data folder "UCI HAR Dataset" is directly contained in project working directory set


##################################################################
#
#   Read raw data
#
#       training set data: x_train.txt
#       training set activity data: y_train.txt
#           This is an additional column that pairs with the observed data
#       training set subject id: subject_train.txt
#           Another column that pairs with the training set
#
#       test set data: x_test.txt
#       test set activity id's: y_test.txt
#           This is an additional column that pairs with the test data
#       test set subject id: subject_test.txt
#           Another column that pairs with the test set
#
#       feature list: features.txt
#           names of features that make up the columns in training set and test set
#
#       activity labels: interprets the id's used in activity data with human readable labels:
#           activity_labels.txt
#

# set variables to all source data

datafile_train <- "UCI HAR Dataset\\train\\X_train.txt"
datafile_train_activity <- "UCI HAR Dataset\\train\\Y_train.txt"
datafile_train_subject <- "UCI HAR Dataset\\train\\subject_train.txt"
datafile_test <- ".\\UCI HAR Dataset\\test\\X_test.txt"
datafile_test_activity <- ".\\UCI HAR Dataset\\test\\Y_test.txt"
datafile_test_subject <- "UCI HAR Dataset\\test\\subject_test.txt"
datafile_features <- ".\\UCI HAR Dataset\\features.txt"
datafile_activityLabels <- ".\\UCI HAR Dataset\\activity_labels.txt"

# read features

df_featuresTable <- read.table(datafile_features, header = FALSE)
colnames(df_featuresTable) <- c("index", "name")
df_features <- as.character(df_featuresTable$name) # don't want factor
# add two new columns to the list: subjectid, activityid
# Those will also be added to the datafram
df_featuresAdditional <- c("subjectid", "activityid")
df_features <- c(df_features, df_featuresAdditional)

# read data sets

df_train <- read.table(datafile_train, header = FALSE)
df_train_subject <- read.table(datafile_train_subject, header = FALSE)
df_train_activity <- read.table(datafile_train_activity, header = FALSE)
df_train <- cbind(df_train, df_train_subject, df_train_activity)
colnames(df_train) <- df_features

df_test <- read.table(datafile_test, header = FALSE)
df_test_subject <- read.table(datafile_test_subject, header = FALSE)
df_test_activity <- read.table(datafile_test_activity, header = FALSE)
df_test <- cbind(df_test, df_test_subject, df_test_activity)
colnames(df_test) <- df_features

# read interpretation of activities

df_activityLabels <- read.table(datafile_activityLabels, header = FALSE)

########################################
#
# Task 1: Merge training and test Data sets

df_merge <- rbind(df_train, df_test)
# sanity checks
# str(df_test[,1:5])
# str(df_train[,1:5])
# str(df_merge[,1:5])

# summary(df_merge)

#######################################
#
#   Task 2: Identify factors with 'mean' and 'std' in the name
#       and extract only those columns

featureIsMeanOrStd <- function(featurename)
{
    # pattern to include means
    # this does not include derivations of means, such as angle(X, gravityMean)
    patternOfMean <- "[a-zA-Z_-]*mean.*"
    containsMean <- regexpr(pattern = patternOfMean, text = featurename)
    
    # pattern to include standard deviation fields
    # this does not include derivations of std, such as angle(X, gravityStd), if such a thing exists
    patternOfSd <- "[a-zA-Z_-]*std.*"
    containsSd <- regexpr(pattern = patternOfSd, text = featurename)
    
    containsMeanOrSd <- containsMean > 0 | containsSd > 0
    containsMeanOrSd
}

featuresHaveMeanOrSd <- sapply(df_features, featureIsMeanOrStd)

# the features that are either mean or sd

df_features_meanOrSd <- df_features[featuresHaveMeanOrSd]

# This is data set with only the mean and sd features

df_meanOrSd <- df_merge[, df_features_meanOrSd]

# Add subject id and activity id back in

df_subjectid <- data.frame(subjectid = df_merge$subjectid)
df_activityid <-  data.frame(activityid = df_merge$activityid)
df2 <- cbind(df_meanOrSd, df_subjectid, df_activityid)
df2_features <- colnames(df2)

# result:
# df2


# sanity check
# head(df2)

################################################################
#
#   Task 3: Include descriptive activity names
#

# function converts a number to the appropriate activity label

getActivityLabel <- function(number)
{
    # df_activityLabels[df_activityLabels$V1 == number]
    
    label <-  as.character(df_activityLabels[df_activityLabels$V1 == number, ]$V2)
    
    label
}

# add column to data frame that contains activity label

df2_activitylabels <- data.frame(activitylabel = sapply(X = df2$activityid, FUN = getActivityLabel))
df3 = cbind(df2, df2_activitylabels)

# result
# df3

##################################################################
#
#   Task 4: Label data frame with appropriate, readable variable names
#

# function "cleans" names
# uses a very targeted replacement of punctuation characters
# for readability leaves or inserts '_' (in programming, '_' is considered a letter, for that reason)
cleanName <- function(featurename)
{
    cleanedFeatureName <- gsub(pattern = "[()]", replacement = "", x = featurename, ignore.case = TRUE)
    cleanedFeatureName <- gsub(pattern = "-", replacement = "_", x = cleanedFeatureName, ignore.case = TRUE)
    cleanedFeatureName <- gsub(pattern = "_mean", replacement = "_MEAN", x = cleanedFeatureName, ignore.case = TRUE)
    cleanedFeatureName <- gsub(pattern = "_std", replacement = "_SD", x = cleanedFeatureName, ignore.case = TRUE)
    cleanedFeatureName <- gsub(pattern = ",", replacement = "_", x = cleanedFeatureName, ignore.case = TRUE)
    cleanedFeatureName
}

df3_features <- colnames(df3)

df3_features_clean <- sapply(X = df3_features, FUN = cleanName)

df4 <- df3

colnames(df4) <- df3_features_clean

# Testing:
# head(df4)


###########################################################################
#
#   Task 5: Create another data set
#           tidy data set
#           group by: subject, activity
#           summarize each variable by taking the average
#

require(reshape2)

# define the source of this task
# not clear: could be total data set or just the subset with mean and Sd columns
# take previous data set

# remove column "activityid", since we have "activitylabel" and don't want duplication (not tidy)
drops <- c("activityid")
df5temp <- df4[,!(names(df4) %in% drops)]

df_molten <- melt(df5temp, id = c("subjectid", "activitylabel"), na.rm = TRUE)
df5_final <- dcast(data = df_molten, formula = subjectid + activitylabel ~ variable, fun.aggregate = mean, drop = FALSE)


# results
# df5
# head(df5)

destfile <- "task5.txt"
write.table(df5_final, destfile, sep = "\t", row.names = FALSE)


# setwd(savedwd)