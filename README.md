# Coursera Course 3 - Data Cleaning
(Documentation of Peer Assignment Script)

## Overview

Script: run_analysis.R
Environment:
* Data from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
* Put the directory UCI HAR Dataset (which contains the data) in the same directory as script run_analysis.R
Operation:
* Run the script in RStudio
* Output is a file "task5.txt". It contains the tidy data set requested in step 5 of the peer assignment


## Detailed documentation

### Preparation Step

Script reads the following data:

- Training Data
* Training data set: x_train.txt
* Training set activity data: y_train.txt
* Training set subject id's: subject_train.txt
- Test Data
* Test data set: x_test.txt
* Test set activity data: y_test.txt
* Test set subject id's: subject_test.txt
- Feature List: features.txt
- Activity Lavels: activity_labels.txt

For each test and training data a data frame is initialized. That data frame contains the feature data as column names and has added the subject id data

### Step 1

The two data frames for test and for training data are merged into a single data frame "df_merge"

### Step 2

Each feature name is tested for whether it contains "mean" or "std" (for standard deviation).
Only features with either "mean" or "std" in their name are selected.
A data frame df2 is created that holds only columns with "mean" or "std" in it, or the activityid or subjectid
The selection of "mean" and "std" follows rules:
* case independent
* it doesn't match "mean" or "std" when they appear in parentheses. It looks like we don't want these features

Result: dataframe df2

### Step 3

A function converts activity id's to activity labels.
The data frame df2 is modified to contain an extra column "activitylabel", which interprets the activity id's according to the activity label map read from file.

### Step 4

The feature names (column names) in df3 are "cleaned" to drop punctuation characters. Although using underscores in column names is less than ideal,
they are put into column names here, to retain some readability that the punctuation in the feature names was responsible for.

Result is a data frame df4, which holds the cleaned column names

### Step 5

The dataframe df4 is "melted" (or "unpivoted"), so that for each subjectid and activitylabel, each other variable/value pair occupies one row.
Before that, the column of duplicate meaning, activityid is dropped. It isn't supposed to be in a tidy dataset anyway.

The resulting molten dataframe is then re-aggregated, by taking the mean for each variable name, for each combination of subjectid and activitylabel.

The result is df5.

Df5 is written to disk as "task5.txt" in the same location as this script, as a tab-separated file.

