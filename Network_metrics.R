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
  if(count>14){
    break
  }
  if(count%%7 ==0){
    print(count)
  #Consider data until current timestamp of the loop
  temp = subset(reduced, as.Date(reduced$CreationDate, '%d-%m-%Y') <= as.Date(theDate, '%d-%m-%Y'))
  temp1 = temp[,c("OwnerUserId.x", "OwnerUserId.y")]
  
  #considering only one occurence of link between answer - question
  dataNoDup = temp1[!duplicated(temp1),]
  #create graph
  vertex.attrs <- list(name = unique(c(dataNoDup$OwnerUserId.x, dataNoDup$OwnerUserId.y)))
  edges <- rbind(match(dataNoDup$OwnerUserId.x, vertex.attrs$name),
                 match(dataNoDup$OwnerUserId.y, vertex.attrs$name))
  
  tempg <- graph.empty(n = 0, directed = F)
  tempg <- add.vertices(tempg, length(vertex.attrs$name), attr = vertex.attrs)
  tempg <- add.edges(tempg, edges)
  
  remove(edges)
  remove(vertex.attrs)
  
  #tempg = graph_from_data_frame(dataNoDup,directed = FALSE)
  
  #Betweeness
  b = betweenness(tempg)
  #just storing the values of the nodes which gve an answer in the current timestamp of the for loop
  #needb = b[paste(temp[which(temp$CreationDate == theDate),]$OwnerUserId.x[1:length(temp[which(temp$CreationDate == theDate),]$OwnerUserId.x)])]
  metricBet = rbind(metricBet, data.frame(UserId = names(b),CreationDate = rep(theDate, length(b)), Betweenness = b))
  #metricBet[nrow(metricBet)+1:length(b),] = data.frame(UserId = names(b),CreationDate = rep(theDate, length(b)), Betweenness = b)
  
  #Closeness
  c = closeness(tempg)
  #just storing the values of the nodes which gve an answer in the current timestamp of the for loop
  #needc = c[paste(temp[which(temp$CreationDate == theDate),]$OwnerUserId.x[1:length(temp[which(temp$CreationDate == theDate),]$OwnerUserId.x)])]
  metricClose = rbind(metricClose, data.frame(UserId = names(c),CreationDate = rep(theDate, length(c)), Closness = c))
  #metricClose[nrow(metricClose)+1:length(c),] = data.frame(UserId = names(c),CreationDate = rep(theDate, length(c)), Closeness = c)
  
  #Eigen Centrality
  e = eigen_centrality(tempg)$vector
  #just storing the values of the nodes which gve an answer in the current timestamp of the for loop
  #neede = e[paste(temp[which(temp$CreationDate == theDate),]$OwnerUserId.x[1:length(temp[which(temp$CreationDate == theDate),]$OwnerUserId.x)])]
  metricEig = rbind(metricEig, data.frame(UserId = names(e),CreationDate = rep(theDate, length(e)), EigenCen = e))
  #metricEig[nrow(metricEig)+1:length(e),] = data.frame(UserId = names(e),CreationDate = rep(theDate, length(e)), EigenCen = e)
  
  #Clustering Coefficient
  t = transitivity(tempg, type = "local")
  names(t) = names(b)
  #just storing the values of the nodes which gve an answer in the current timestamp of the for loop
  #needt = t[paste(temp[which(temp$CreationDate == theDate),]$OwnerUserId.x[1:length(temp[which(temp$CreationDate == theDate),]$OwnerUserId.x)])]
  metricClus = rbind(metricClus, data.frame(UserId = names(t),CreationDate = rep(theDate, length(t)), Clustering = t))
  #metricClus[nrow(metricClus)+1:length(t),] = data.frame(UserId = names(t),CreationDate = rep(theDate, length(t)), Clustering = t)
  preDate = theDate
  }
  count = count + 1
  # 
  # if(count>14){
  #   break
  # }
  # 
}

### For Correlation

#Initialize Metric DataFrames
CorBet <- data.frame(UserId = integer(), CreationDate = double(), Betweenness = integer(), stringsAsFactors = FALSE)
CorClose <- data.frame(UserId = integer(), CreationDate = double(), Closeness = integer(), stringsAsFactors = FALSE)
CorEig <- data.frame(UserId = integer(), CreationDate = double(), EigenCen = integer(), stringsAsFactors = FALSE)
CorClus <- data.frame(UserId = integer(), CreationDate = double(), Clustering = integer(), stringsAsFactors = FALSE)


#Calculation of Network Metrics and how they changed over time
count = 0
preDate = "15-09-2008"
for(theDate in unique(reduced$CreationDate)){
  
  if(count%%7 ==0){
    print(count)
    #Consider data until current timestamp of the loop
    temp = subset(reduced, as.Date(reduced$CreationDate, '%d-%m-%Y') <= as.Date(theDate, '%d-%m-%Y'))
    temp1 = temp[,c("OwnerUserId.x", "OwnerUserId.y")]
    
    #considering only one occurence of link between answer - question
    dataNoDup = temp1[!duplicated(temp1),]
    #create graph
    vertex.attrs <- list(name = unique(c(dataNoDup$OwnerUserId.x, dataNoDup$OwnerUserId.y)))
    edges <- rbind(match(dataNoDup$OwnerUserId.x, vertex.attrs$name),
                   match(dataNoDup$OwnerUserId.y, vertex.attrs$name))
    
    tempg <- graph.empty(n = 0, directed = F)
    tempg <- add.vertices(tempg, length(vertex.attrs$name), attr = vertex.attrs)
    tempg <- add.edges(tempg, edges)
    
    remove(edges)
    remove(vertex.attrs)
    
    #tempg = graph_from_data_frame(dataNoDup,directed = FALSE)
    
    #Betweeness
    b = betweenness(tempg)
    #just storing the values of the nodes which gve an answer in the current timestamp of the for loop
    needb = b[paste(unique(temp[which(as.Date(reduced$CreationDate, '%d-%m-%Y') > as.Date(preDate, '%d-%m-%Y') & as.Date(reduced$CreationDate, '%d-%m-%Y') <= as.Date(theDate, '%d-%m-%Y')),]$OwnerUserId.x))]
    CorBet = rbind(CorBet, data.frame(UserId = names(needb),CreationDate = rep(theDate, length(needb)), Betweenness = needb))
    #CorBet[nrow(CorBet)+1:length(b),] = data.frame(UserId = names(b),CreationDate = rep(theDate, length(b)), Betweenness = b)
    
    #Closeness
    c = closeness(tempg)
    #just storing the values of the nodes which gve an answer in the current timestamp of the for loop
    needc = c[paste(unique(temp[which(as.Date(reduced$CreationDate, '%d-%m-%Y') > as.Date(preDate, '%d-%m-%Y') & as.Date(reduced$CreationDate, '%d-%m-%Y') <= as.Date(theDate, '%d-%m-%Y')),]$OwnerUserId.x))]
    CorClose = rbind(CorClose, data.frame(UserId = names(needc),CreationDate = rep(theDate, length(needc)), Closness = needc))
    #CorClose[nrow(CorClose)+1:length(c),] = data.frame(UserId = names(c),CreationDate = rep(theDate, length(c)), Closeness = c)
    
    #Eigen Centrality
    e = eigen_centrality(tempg)$vector
    #just storing the values of the nodes which gve an answer in the current timestamp of the for loop
    neede = e[paste(unique(temp[which(as.Date(reduced$CreationDate, '%d-%m-%Y') > as.Date(preDate, '%d-%m-%Y') & as.Date(reduced$CreationDate, '%d-%m-%Y') <= as.Date(theDate, '%d-%m-%Y')),]$OwnerUserId.x))]
    CorEig = rbind(CorEig, data.frame(UserId = names(neede),CreationDate = rep(theDate, length(neede)), EigenCen = neede))
    #CorEig[nrow(Cor)+1:length(e),] = data.frame(UserId = names(e),CreationDate = rep(theDate, length(e)), EigenCen = e)
    
    #Clustering Coefficient
    t = transitivity(tempg, type = "local")
    names(t) = names(b)
    #just storing the values of the nodes which gve an answer in the current timestamp of the for loop
    needt = t[paste(unique(temp[which(as.Date(reduced$CreationDate, '%d-%m-%Y') > as.Date(preDate, '%d-%m-%Y') & as.Date(reduced$CreationDate, '%d-%m-%Y') <= as.Date(theDate, '%d-%m-%Y')),]$OwnerUserId.x))]
    CorClus = rbind(CorClus, data.frame(UserId = names(needt),CreationDate = rep(theDate, length(needt)), Clustering = needt))
    #CorClus[nrow(metricClus)+1:length(t),] = data.frame(UserId = names(t),CreationDate = rep(theDate, length(t)), Clustering = t)
  }
  count = count + 1
  # 
  # if(count>49){
  #   break
  # }
}


write.csv(metricBet, file = "Between.csv")
write.csv(metricClose, file = "Close.csv")
write.csv(metricEig, file = "Eigen.csv")
write.csv(metricClus, file = "Clustering.csv")



