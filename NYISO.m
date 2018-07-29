summary=zeros(10,11);
s=1;
result={};
operation={};
ng_price=readtable('NG_price.csv'); 
ng_price.Month=datetime(ng_price.Month,'Format','MMM yy');

for y=2007:2016
data=readtable([num2str(y),'_raw_as.csv']);

rdata2=array2table(zeros(height(data),9),'VariableNames',{'ng_price','mc','r_e','r_10_sr','r_10_nsr','r_30_or','r_reg','income','operation'});
h_data=[data,rdata2];
disp("ng_price");
for j=1:height(ng_price)
    if ng_price.Month(j).Year==y-2000
        for i=1:height(h_data)
            if h_data.time_stamp(i).Month==ng_price.Month(j).Month
               h_data.ng_price(i)=ng_price.Price(j);
            end
        end
    end
end
disp("income");      

income=0;
tot_op=0;
mc_energy=0;
mc_rrs=0;
mc_reg=0;
for i=1:height(h_data)
    h_data.mc(i)=((h_data.ng_price(i)/1.037)*9.750)+(10.37*1.68); %((fuel_cost)/thousand_cu_ft to m_btu) * ht_rate)+(var_o&m * location_fact)
    if h_data.TWIZonalLBMP(i)>=h_data.mc(i)
        income_energy=50*h_data.TWIZonalLBMP(i);
        h_data.r_e(i)=income_energy;
        mc_energy=mc_energy+(h_data.mc(i)*50);
        h_data.r_ns(i)=0;
        h_data.operation(i)=1;
    else
        as_10_nsr_temp=h_data.East10MinNon_SynchronousReserve(i)*50;
        
        as_30_nsr_temp=h_data.East30MinOperatingReserve___MWH_(i)*50;
        
        r_10_sr_temp=20*h_data.TWIZonalLBMP(i)+30*h_data.East10MinSpinningReserve___MWH_(i);
        
        r_reg_temp=35*h_data.TWIZonalLBMP(i)+15*h_data.EastRegulation___MWH_(i);
        
        as_nsr_temp=max([as_10_nsr_temp,as_30_nsr_temp]);
    
        if (max([r_10_sr_temp-20*h_data.mc(i),r_reg_temp-35*h_data.mc(i), as_nsr_temp])==r_10_sr_temp-20*h_data.mc(i) && r_10_sr_temp-20*h_data.mc(i)>0)
          h_data.r_10_sr(i)=r_10_sr_temp; 
          mc_rrs=mc_rrs+20*h_data.mc(i);
          h_data.r_ns(i)=0;
          h_data.operation(i)=2; 
        elseif (max([r_10_sr_temp-20*h_data.mc(i),r_reg_temp-35*h_data.mc(i), as_nsr_temp])==r_reg_temp-35*h_data.mc(i) && r_reg_temp-35*h_data.mc(i)>0)
          h_data.r_reg(i)=r_reg_temp;
          mc_reg=mc_reg+35*h_data.mc(i);
          h_data.r_ns(i)=0;
          h_data.operation(i)=4; 
        else
            h_data.r_ns(i)=as_nsr_temp;
            h_data.r_rs(i)=0;
            h_data.operation(i)=3; 
        end
 
        income_energy=0;
        h_data.r_e(i)=income_energy;
        
    end

    tot_op=tot_op+h_data.operation(i);
   
    h_data.income(i)=h_data.r_e(i)+h_data.r_10_sr(i)+h_data.r_ns(i)+h_data.r_reg(i);
    income=income+h_data.income(i);
    
end

result{y-2006}=h_data;
operation{y-2006}=tabulate(h_data.operation);
summary(s,1)=y;
summary(s,2)=income;
summary(s,3)=tot_op;
summary(s,4)=mc_energy+mc_rrs+mc_reg;
summary(s,5)=sum(h_data.r_e);
summary(s,6)=sum(h_data.r_10_sr);
summary(s,7)=sum(h_data.r_ns);
summary(s,8)=sum(h_data.r_reg);
summary(s,9)=mc_energy;
summary(s,10)=mc_rrs;
summary(s,11)=mc_reg;
s=s+1;
end
sum_table=array2table(summary);
sum_table.Properties.VariableNames={'Year' 'Revenue' 'Hours_Op' 'Total_MC' 'Rev_Energy' 'Rev_10_SR' 'Rev_NS' 'Rev_REG' 'Energy_MC' 'SR_MC' ,'REG_MC'};
