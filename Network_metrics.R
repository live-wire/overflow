library(igraph)
library(datetime)
## Read Files
ques = read.csv("r_questions.csv", sep=",")
ans = read.csv("r_answers.csv", sep = ",")

##Join answer and question Files based on question ID
merged <- merge(ans,ques , by.x = "ParentId", by.y = "Id")

##Take necessary stuff
reduced = merged[, c("OwnerUserId.x", "CreationDate.x", "OwnerUserId.y")]
reduced = reduced[order(reduced$CreationDate.x),]

##clean date format
reduced["CreationDate"] = format(as.POSIXct(strptime(reduced$CreationDate.x, format = "%Y-%m-%dT%H:%M:%S", tz= "")), format = "%d-%m-%Y")
reduced <-na.omit(reduced)


#Initialize Metric DataFrames
metricBet <- data.frame(UserId = integer(), CreationDate = double(), Betweenness = integer(), stringsAsFactors = FALSE)
metricClose <- data.frame(UserId = integer(), CreationDate = double(), Closeness = integer(), stringsAsFactors = FALSE)
metricEig <- data.frame(UserId = integer(), CreationDate = double(), EigenCen = integer(), stringsAsFactors = FALSE)
metricClus <- data.frame(UserId = integer(), CreationDate = double(), Clustering = integer(), stringsAsFactors = FALSE)


#Calculation of Network Metrics and how they changed over time
count = 0
for(theDate in unique(reduced$CreationDate)){
  #Consider data until current timestamp of the loop
  temp = subset(reduced, as.Date(reduced$CreationDate, '%d-%m-%Y') <= as.Date(theDate, '%d-%m-%Y'))
  temp1 = temp[,c("OwnerUserId.x", "OwnerUserId.y")]
  
  #considering only one occurence of link between answer - question
  dataNoDup = temp1[!duplicated(temp1),]
  #create graph
  tempg = graph_from_data_frame(dataNoDup,directed = FALSE)
  
  #Betweeness
  b = betweenness(tempg)
  #just storing the values of the nodes which gve an answer in the current timestamp of the for loop
  needb = b[paste(temp[which(temp$CreationDate == theDate),]$OwnerUserId.x[1:length(temp[which(temp$CreationDate == theDate),]$OwnerUserId.x)])]
  #metricBet = rbind(metricBet, data.frame(UserId = names(needb),CreationDate = rep(theDate, length(needb)), Betweenness = needb))
  metricBet[nrow(metricBet)+1:length(needb),] = data.frame(UserId = names(needb),CreationDate = rep(theDate, length(needb)), Betweenness = needb)
  
  #Closeness
  c = closeness(tempg)
  #just storing the values of the nodes which gve an answer in the current timestamp of the for loop
  needc = c[paste(temp[which(temp$CreationDate == theDate),]$OwnerUserId.x[1:length(temp[which(temp$CreationDate == theDate),]$OwnerUserId.x)])]
  #metricClose = rbind(metricClose, data.frame(UserId = names(needc),CreationDate = rep(theDate, length(needc)), Closness = needc))
  metricClose[nrow(metricClose)+1:length(needc),] = data.frame(UserId = names(needc),CreationDate = rep(theDate, length(needc)), Closeness = needc)
  
  #Eigen Centrality
  e = eigen_centrality(tempg)$vector
  #just storing the values of the nodes which gve an answer in the current timestamp of the for loop
  neede = e[paste(temp[which(temp$CreationDate == theDate),]$OwnerUserId.x[1:length(temp[which(temp$CreationDate == theDate),]$OwnerUserId.x)])]
  #metricEig = rbind(metricEig, data.frame(UserId = names(neede),CreationDate = rep(theDate, length(neede)), EigenCen = neede))
  metricEig[nrow(metricEig)+1:length(neede),] = data.frame(UserId = names(neede),CreationDate = rep(theDate, length(neede)), EigenCen = neede)
  
  #Clustering Coefficient
  t = transitivity(tempg, type = "local")
  names(t) = names(b)
  #just storing the values of the nodes which gve an answer in the current timestamp of the for loop
  needt = t[paste(temp[which(temp$CreationDate == theDate),]$OwnerUserId.x[1:length(temp[which(temp$CreationDate == theDate),]$OwnerUserId.x)])]
  #metricClus = rbind(metricClus, data.frame(UserId = names(needt),CreationDate = rep(theDate, length(needt)), Clustering = needt))
  metricClus[nrow(metricClus)+1:length(needt),] = data.frame(UserId = names(needt),CreationDate = rep(theDate, length(needt)), Clustering = needt)
  count = count + 1
  print(count)
  # if(count>10){
  #   break
  # }
}

write.csv(metricBet, file = "Between.csv")
write.csv(metricClose, file = "Close.csv")
write.csv(metricEig, file = "Eigen.csv")
write.csv(metricClus, file = "Clustering.csv")



