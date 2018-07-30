require(readxl)
install.packages("lubridate")
require(lubridate)

files<-list.files(path=".",pattern="rpt")
data<-data[-which(row.names(data)==row.names(data)),]
read_sheet<-function()
{
for (i in 1:length(files))
{
  sheets<-excel_sheets(files[i])
  for (j in 1:length(sheets))
  {
    temp<-read_excel(files[i],sheet = sheets[j],col_names = T)
    temp<-temp[grep("HOUSTON", temp$`Settlement Point Name`),]
    print(nrow(temp))
    data<-rbind(data,temp)
  }
  
}
return(data)
}


days<-levels(factor(data$`Delivery Date`))
hours<-levels(factor(data$`Delivery Hour`))

data_avg<-data[-which(row.names(data)==row.names(data)),]
ind=1

for (d in 1:length(days))
{
  for (h in 1:24)
  {
    ind_avg<-which(data$`Delivery Date`==days[d] & data$`Delivery Hour`==h)
    avg<-mean(data$`Settlement Point Price`[ind_avg])
    data_avg[ind,]<-data[min(ind_avg),]
    data_avg$`Settlement Point Price`[ind]<-avg
    ind=ind+1
  }
  print(days[d])
}

avg_price_2010<-data_avg[grep("2010",as.character(data_avg$`Delivery Date`)),]
avg_price_2011<-data_avg[grep("2011",as.character(data_avg$`Delivery Date`)),]
avg_price_2012<-data_avg[grep("2012",as.character(data_avg$`Delivery Date`)),]
avg_price_2013<-data_avg[grep("2013",as.character(data_avg$`Delivery Date`)),]
avg_price_2014<-data_avg[grep("2014",as.character(data_avg$`Delivery Date`)),]
avg_price_2015<-data_avg[grep("2015",as.character(data_avg$`Delivery Date`)),]
avg_price_2016<-data_avg[grep("2016",as.character(data_avg$`Delivery Date`)),]
avg_price_2017<-data_avg[grep("2017",as.character(data_avg$`Delivery Date`)),]

avg_price_2010$`Delivery Date`<-paste(avg_price_2010$`Delivery Date`,paste(avg_price_2010$`Delivery Hour`,"00","00",sep=":"),sep=" ")
avg_price_2010$`Delivery Date`<-strptime(avg_price_2010$`Delivery Date`,"%m/%d/%Y %H:%M:%S")
write.csv(avg_price_2010,"2010_raw.csv",row.names = F,na="")

avg_price_2011$`Delivery Date`<-paste(avg_price_2011$`Delivery Date`,paste(avg_price_2011$`Delivery Hour`,"00","00",sep=":"),sep=" ")
avg_price_2011$`Delivery Date`<-strptime(avg_price_2011$`Delivery Date`,"%m/%d/%Y %H:%M:%S")
write.csv(avg_price_2011,"2011_raw.csv",row.names = F,na="")

avg_price_2012$`Delivery Date`<-paste(avg_price_2012$`Delivery Date`,paste(avg_price_2012$`Delivery Hour`,"00","00",sep=":"),sep=" ")
avg_price_2012$`Delivery Date`<-strptime(avg_price_2012$`Delivery Date`,"%m/%d/%Y %H:%M:%S")
write.csv(avg_price_2012,"2012_raw.csv",row.names = F,na="")

avg_price_2013$`Delivery Date`<-paste(avg_price_2013$`Delivery Date`,paste(avg_price_2013$`Delivery Hour`,"00","00",sep=":"),sep=" ")
avg_price_2013$`Delivery Date`<-strptime(avg_price_2013$`Delivery Date`,"%m/%d/%Y %H:%M:%S")
write.csv(avg_price_2013,"2013_raw.csv",row.names = F,na="")

avg_price_2014$`Delivery Date`<-paste(avg_price_2014$`Delivery Date`,paste(avg_price_2014$`Delivery Hour`,"00","00",sep=":"),sep=" ")
avg_price_2014$`Delivery Date`<-strptime(avg_price_2014$`Delivery Date`,"%m/%d/%Y %H:%M:%S")
write.csv(avg_price_2014,"2014_raw.csv",row.names = F,na="")

avg_price_2015$`Delivery Date`<-paste(avg_price_2015$`Delivery Date`,paste(avg_price_2015$`Delivery Hour`,"00","00",sep=":"),sep=" ")
avg_price_2015$`Delivery Date`<-strptime(avg_price_2015$`Delivery Date`,"%m/%d/%Y %H:%M:%S")
write.csv(avg_price_2015,"2015_raw.csv",row.names = F,na="")

avg_price_2016$`Delivery Date`<-paste(avg_price_2016$`Delivery Date`,paste(avg_price_2016$`Delivery Hour`,"00","00",sep=":"),sep=" ")
avg_price_2016$`Delivery Date`<-strptime(avg_price_2016$`Delivery Date`,"%m/%d/%Y %H:%M:%S")
write.csv(avg_price_2016,"2016_raw.csv",row.names = F,na="")

avg_price_2017$`Delivery Date`<-paste(avg_price_2017$`Delivery Date`,paste(avg_price_2017$`Delivery Hour`,"00","00",sep=":"),sep=" ")
avg_price_2017$`Delivery Date`<-strptime(avg_price_2017$`Delivery Date`,"%m/%d/%Y %H:%M:%S")
write.csv(avg_price_2017,"2017_raw.csv",row.names = F,na="")




