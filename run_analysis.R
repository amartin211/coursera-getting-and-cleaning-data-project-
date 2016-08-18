library(dplyr)

fileUrl<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download(fileUrl,dest="C:/Users/alex/Desktop/R _ Coursera/dataset.zip", mode="wb")
unzip ("dataset.zip", exdir = "./mydata")
testset<-read.table("./mydata/UCI HAR Dataset/test/X_test.txt")
trainingset<-read.table("./mydata/UCI HAR Dataset/train/X_train.txt")


# Merging the data set
alldata<-merge(testset,trainingset,all=TRUE)
 

#Loading descriptive variable names
  feature<-read.table("./mydata/UCI HAR Dataset/features.txt")
#replacing variable names in alldata
  colnames(alldata) <- make.names(feature$V2, unique=TRUE)
#selecting only columns where variable names match "mean" and "std"
  meanstddata<-select(alldata,matches("mean|std"))

# Loading descriptive activity names
  desc_train<-read.table("./mydata/UCI HAR Dataset/train/y_train.txt")
  desc_test<-read.table("./mydata/UCI HAR Dataset/test/y_test.txt")

# combining descriptive activity names together
  complete_desc<-rbind(desc_test,desc_train)

# Loading activity names
  activity_label<-read.table("./mydata/UCI HAR Dataset/activity_labels.txt")

  colnames(complete_desc)<-c("activity_description")
  colnames(activity_label)<-c("activity_num","activity")

# Loading subjects
  subject_test<-read.table("./mydata/UCI HAR Dataset/test/subject_test.txt")
  subject_train<-read.table("./mydata/UCI HAR Dataset/train/subject_train.txt")

#Combining subjects
  conbined_subject<-rbind(subject_test,subject_train)
 
  colnames(conbined_subject)<-c("subject_id")

#Combining all tables by adding activity and subject columns. 
  total_combined<-cbind(meanstddata,complete_desc,conbined_subject)
# replacing activity label by their names
  activity_data<-tbl_df(merge(x=total_combined,y=activity_label,by.x="activity_description",by.y="activity_num",sort=FALSE))
  
# removing activity_description column
  finaldata<-select(activity_data,-activity_description)
  
# Cleaning variables names to reflect appropriate descriptive variables.
  clean_data<-gsub("\\."," ",names(finaldata))
  clean_data<-gsub("fBody","Body",clean_data)
  clean_data<-gsub("tBody","Body",clean_data)
  clean_data<-gsub("tGravity","Gravity",clean_data)
  clean_data<-gsub(".1","", clean_data)

# Reallocate clean variable column names into the data frame.
  colnames(finaldata)<-make.names(clean_data,unique=TRUE)

# Group data by mean for activity and subject 
  tidymeandata<- finaldata %>% group_by(activity,subject_id) %>% summarise_each(funs(mean(., na.rm=TRUE)))

# Wrting outcome in a text format
  write.table(tidymeandata, "tidy.txt", row.names = FALSE, quote = FALSE)

