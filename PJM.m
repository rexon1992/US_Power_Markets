summary=zeros(11,12);
s=1;
result={};
operation={};
ng_price=readtable('NG_price.csv'); 
ng_price.Month=datetime(ng_price.Month,'Format','MMM-yyyy');
%plot(ng_price.Month,ng_price.Price); 

for y=2007:2017
data=readtable([num2str(y),'_pepco.csv']);

%{
pjm.PUBLISHDATE=datetime(pjm.PUBLISHDATE,'Format','MM-dd-yyyy');
pjm = sortrows(pjm,'PUBLISHDATE','ascend');
pjm(:,10)=[];
data=readtable('2016_raw.csv');
data(:,[1:32])=[];
int=4;
d=0;
for f=drange(1:int:(height(pjm)-(int-1)))
        for g=0:23
            x=0;
            d=d+1;
            for c=0:(int-1)
            x=x+table2array(pjm(f+c,g+8));
            end
        data.EasternDateHour(d)=datetime(pjm.PUBLISHDATE(f).Year,pjm.PUBLISHDATE(f).Month,pjm.PUBLISHDATE(f).Day,g,0,0);
        data.TWIZonalLBMP(d)=x/int;
        
        %disp(d);
        end
end
%}

rdata2=array2table(zeros(height(data),8),'VariableNames',{'ng_price','mc','rev_en','rev_sync','rev_nsync','rev_reg','income','operation'});
h_data=[data,rdata2];

for j=1:184
    if ng_price.Month(j).Year==y-2000
        for i=1:height(h_data)
            if h_data.datetime_beginning_utc(i).Month==ng_price.Month(j).Month
               h_data.ng_price(i)=ng_price.Price(j);
            end
        end
    end
end
      

income=0;
tot_op=0;
mc_energy=0;
mc_rrs=0;
mc_reg=0;
for i=1:height(h_data)
    h_data.mc(i)=((h_data.ng_price(i)/1.037)*9.750)+(10.37*1.06); %((fuel_cost)/thousand_cu_ft to m_btu) * ht_rate)+(var_o&m * location_fact)
    if h_data.avg_lmp_rt(i)>=h_data.mc(i)
        income_energy=50*h_data.avg_lmp_rt(i);
        h_data.rev_en(i)=income_energy;
        mc_energy=mc_energy+(h_data.mc(i)*50);
        h_data.r_ns(i)=0;
        h_data.operation(i)=1;
    else
       
        rev_sync_temp=20*h_data.avg_lmp_rt(i)+30*h_data.sync(i);
        
        rev_reg_temp=35*h_data.avg_lmp_rt(i)+15*h_data.reg(i);
        
        rev_nsync_temp=h_data.nsync(i)*50;
    
        if (max([rev_sync_temp-20*h_data.mc(i),rev_reg_temp-35*h_data.mc(i), rev_nsync_temp])==rev_sync_temp-20*h_data.mc(i) && rev_sync_temp-20*h_data.mc(i)>0)
          h_data.rev_sync(i)=rev_sync_temp; 
          mc_rrs=mc_rrs+20*h_data.mc(i);
          %h_data.r_ns(i)=0;
          h_data.operation(i)=2; 
        elseif (max([rev_sync_temp-20*h_data.mc(i),rev_reg_temp-35*h_data.mc(i), rev_nsync_temp])==rev_reg_temp-35*h_data.mc(i) && rev_reg_temp-35*h_data.mc(i)>0)
          h_data.rev_reg(i)=rev_reg_temp;
          mc_reg=mc_reg+35*h_data.mc(i);
          %h_data.r_ns(i)=0;
          h_data.operation(i)=4; 
        else
            h_data.rev_nsync(i)=rev_nsync_temp;
            %h_data.r_rs(i)=0;
            h_data.operation(i)=3; 
        end
 
        %income_energy=0;
        %h_data.r_e(i)=income_energy;
        
    end

    tot_op=tot_op+h_data.operation(i);
   
    h_data.income(i)=h_data.rev_en(i)+h_data.rev_sync(i)+h_data.rev_nsync(i)+h_data.rev_reg(i);
    income=income+h_data.income(i);
    
end

result{y-2006}=h_data;
writetable(h_data,[num2str(y),'_pepco_output.csv']);
operation=tabulate(h_data.operation);
summary(s,1)=y;
summary(s,2)=income;
summary(s,3)=tot_op;
summary(s,4)=mc_energy+mc_rrs+mc_reg;
summary(s,5)=sum(h_data.rev_en);
summary(s,6)=sum(h_data.rev_sync);
summary(s,7)=sum(h_data.rev_nsync);
summary(s,8)=sum(h_data.rev_reg);
summary(s,9)=mc_energy;
summary(s,10)=mc_rrs;
summary(s,11)=mc_reg;
summary(s,12)=operation(1,2);
%summary(s,13)=operation(2,2);
%summary(s,14)=operation(3,2);
%summary(s,15)=operation(4,2);

s=s+1;
end
sum_table=array2table(summary);
sum_table.Properties.VariableNames={'Year' 'Revenue' 'Hours_Op' 'Total_MC' 'Rev_Energy' 'Rev_10_SR' 'Rev_NS' 'Rev_REG' 'Energy_MC' 'SR_MC' ,'REG_MC','OP_E',};
