library(lubridate)
library(compare)
regions<-read.csv("zone_region.csv",header=T, check.names = F, stringsAsFactors = F)

for (r in 1:nrow(regions))
{
  dir<-paste(".",regions$Zone[r], sep = "/")
  dir_as<-paste(".","ancillary_services/price_data/output",sep="/")
  lmp_files<-list.files(path=dir,pattern = "_raw.csv")
  as_files<-list.files(path=dir_as)
  for (year in 2016:2016)
  {
    temp_lmp<-read.csv(paste(dir,lmp_files[grep(year,lmp_files)],sep="/"),header = T,check.names = F,stringsAsFactors = F)
    temp_lmp$`Eastern Date Hour`<-strptime(temp_lmp$`Eastern Date Hour`,format = "%Y/%m/%d %H:%M:%S")
    temp_lmp$`Eastern Date Hour`<-as.character(temp_lmp$`Eastern Date Hour`)
    colnames(temp_lmp)[1]="time_stamp"
    
    as_files_year<-as_files[grep(year,as_files)]
    
    if (length(as_files_year)==1){
      temp_as<-read.csv(paste(dir_as,as_files_year,sep = "/"),header = T, check.names = F, stringsAsFactors = F)
      if(year!=2015){
      temp_as$date<-strptime(temp_as$date,format = "%Y-%m-%d %H:%M:%S")
      }
      if(year==2015){
        temp_as$date<-strptime(paste(temp_as$date,":00",sep=""),format = "%m/%d/%y %H:%M:%S")
      }      
      
      temp_as$date<-as.character(temp_as$date)
      colnames(temp_as)[1]="time_stamp"
      
      region<-regions$Region[r]
      col_as<-grep(region,colnames(temp_as), ignore.case = T)
      temp_as<-temp_as[,c(1,col_as)]
      
      temp<-merge(temp_lmp,temp_as,by="time_stamp")
      
      to_del<-which(temp=="Inf" | temp=="" | is.na(temp)==T ,arr.ind = T)
      print(nrow(to_del))
      if (nrow(to_del)>0)
      {
        for(i in 1:nrow(to_del))
        {
          temp[to_del[i,1],to_del[i,2]]=0
        }
      }
      temp$time_stamp<-strptime(temp$time_stamp,format = "%Y-%m-%d %H:%M:%S")
      write.csv(temp,paste(dir,paste(year,"raw_as.csv",sep = "_"),sep = "/"),row.names = F,na="0")
      
    }
    if (year==2016){
    as_files_region<-as_files_year[grep(regions$Zone[r],as_files_year, ignore.case = T)]
    as_file_nozone<-as_files_year[grep("zone",as_files_year,ignore.case = T)]
    
    temp_as<-read.csv(paste(dir_as,as_files_region,sep = "/"),header = T, check.names = F, stringsAsFactors = F)
    temp_as$date<-strptime(temp_as$date,format = "%Y-%m-%d %H:%M:%S")
    temp_as$date<-as.character(temp_as$date)
    colnames(temp_as)[1]="time_stamp"
    
    temp_as_nz<-read.csv(paste(dir_as,as_file_nozone,sep = "/"),header = T, check.names = F, stringsAsFactors = F)
    temp_as_nz$date<-strptime(temp_as_nz$date,format = "%Y-%m-%d %H:%M:%S")
    temp_as_nz$date<-as.character(temp_as_nz$date)
    colnames(temp_as_nz)[1]="time_stamp"
    region<-regions$Region[r]
    col_as<-grep(region,colnames(temp_as_nz), ignore.case = T)
    temp_as_nz<-temp_as_nz[,c(1,col_as)]
    temp<-merge(temp_lmp,temp_as_nz,by="time_stamp")
    
    switch=which(as.character(temp_as$time_stamp)=="2016-06-23 00:00:00")
    
    spin_res<-grep("Spinning Reserve",colnames(temp))
    non_spin<-grep("Non-Synchronous Reserve",colnames(temp))
    op_res<-grep("Operating Reserve",colnames(temp))
    reg<-grep("Regulation",colnames(temp))
    
    temp[c(switch:nrow(temp)),spin_res]<-temp_as$`10 Min Spinning Reserve ($/MWH)`[c(switch:nrow(temp))]
    temp[c(switch:nrow(temp)),non_spin]<-temp_as$`10 Min Non-Synchronous Reserve ($/MWH)`[c(switch:nrow(temp))]
    temp[c(switch:nrow(temp)),op_res]<-temp_as$`30 Min Operating Reserve ($/MWH)`[c(switch:nrow(temp))]
    temp[c(switch:nrow(temp)),reg]<-temp_as$`NYCA Regulation Capacity ($/MWH)`[c(switch:nrow(temp))]
   
    to_del<-which(temp=="Inf" | temp=="" | is.na(temp)==T ,arr.ind = T)
    print(nrow(to_del))
    if (nrow(to_del)>0)
    {
      for(i in 1:nrow(to_del))
      {
        temp[to_del[i,1],to_del[i,2]]=0
      }
    }
    
    temp$time_stamp<-strptime(temp$time_stamp,format = "%Y-%m-%d %H:%M:%S")
    write.csv(temp,paste(dir,paste(year,"raw_as.csv",sep = "_"),sep = "/"),row.names = F,na='0')
    
    }
  }
}