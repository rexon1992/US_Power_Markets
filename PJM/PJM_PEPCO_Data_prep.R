pepco_files<-list.files("./PEPCO-DC",pattern="raw")

comed_files<-list.files("./PJM-Chicago",pattern="raw")

as<-read.csv("./Ancillary services/ancillary_services.csv",check.names = F,header = T, stringsAsFactors = F)

as$datetime_beginning_utc<-strptime(as$datetime_beginning_utc, format="%m/%d/%Y %I:%M:%S %p")

energy<-read.csv("./PJM-Chicago/rt_da_monthly_lmps-3.csv",check.names = F,header = T, stringsAsFactors = F)

energy$datetime_beginning_utc<-strptime(energy$datetime_beginning_utc, format="%m/%d/%Y %I:%M:%S %p")

reg<-unique(energy$pnode_name)

temp_bri<-energy[which(energy$pnode_name==reg[1]),]
temp_bur<-energy[which(energy$pnode_name==reg[2]),]
temp_cha<-energy[which(energy$pnode_name==reg[3]),]

temp_bri$avg_lmp_rt<-rowMeans(cbind(temp_bri$total_lmp_rt,temp_bur$total_lmp_rt,temp_cha$total_lmp_rt))

pepco_data<-temp_bri[,c(which(colnames(temp_bri)=="datetime_beginning_utc"),which(colnames(temp_bri)=="avg_lmp_rt"))]

services<-unique(as$ancillary_service)

temp_spin_r<-as[which(as$ancillary_service=="RTO Synchronized Reserve"),which(colnames(as)=="datetime_beginning_utc"|colnames(as)=="value")]
temp_non_spin<-as[which(as$ancillary_service=="RTO Non-Synchronized Reserve"),which(colnames(as)=="datetime_beginning_utc"|colnames(as)=="value")]
temp_reg<-as[which(as$ancillary_service=="RTO Regulation Capability"),which(colnames(as)=="datetime_beginning_utc"|colnames(as)=="value")]

colnames(temp_spin_r)[1]<-"datetime_beginning_utc"
colnames(temp_non_spin)[1]<-"datetime_beginning_utc"
colnames(temp_reg)[1]<-"datetime_beginning_utc"

colnames(temp_spin_r)[which(colnames(temp_spin_r)=="value")]<-"sync"
colnames(temp_non_spin)[which(colnames(temp_non_spin)=="value")]<-"nsync"
colnames(temp_reg)[which(colnames(temp_reg)=="value")]<-"reg"

pepco_data$datetime_beginning_utc<-as.character(pepco_data$datetime_beginning_utc)
temp_spin_r$datetime_beginning_utc<-as.character(temp_spin_r$datetime_beginning_utc)
temp_non_spin$datetime_beginning_utc<-as.character(temp_non_spin$datetime_beginning_utc)
temp_reg$datetime_beginning_utc<-as.character(temp_reg$datetime_beginning_utc)

pepco_data<-merge(pepco_data,temp_spin_r,by="datetime_beginning_utc",all = T)
pepco_data<-merge(pepco_data,temp_non_spin,by="datetime_beginning_utc",all = T)
pepco_data<-merge(pepco_data,temp_reg,by="datetime_beginning_utc",all = T)

pepco_data$datetime_beginning_utc<-strptime(pepco_data$datetime_beginning_utc,format = "%Y-%m-%d %H:%M:%S")



for (year in 2007:2017)
{
  temp<-pepco_data[which(year(pepco_data$datetime_beginning_utc)==year),]
  write.csv(temp,paste("./PJM-Chicago/",year,"_comed.csv",sep=""),row.names = F, na="0")
}
  
  
  
output<-list.files("./PEPCO-DC",pattern="_output.csv")

data<-do.call(rbind,lapply(paste("./PEPCO-DC",output,sep="/"),read.csv,header=T,check.names=F))
write.csv(data,"pepco_output.csv",row.names = F,na="")  
  
data<-read.table("eps-1.4.0-us BAU data.tab",fill=T)  
  
  
  

