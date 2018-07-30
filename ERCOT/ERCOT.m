summary=zeros(8,13);
s=1;
result={};
operation={};
ng_price=readtable('ERCOT_ng_price.csv'); 
ng_price.Month=datetime(ng_price.Month,'Format','MMM yyyy');

for y=2010:2017
data=readtable([num2str(y),'_input.csv']);

rdata2=array2table(zeros(height(data),9),'VariableNames',{'ng_price','mc','r_e','r_rs','r_ns','r_ru','r_rd','income','operation'});
h_data=[data,rdata2];
disp("ng_price");
for j=1:height(ng_price)
    if ng_price.Month(j).Year==y-2000
        for i=1:height(h_data)
            if h_data.DeliveryDate(i).Month==ng_price.Month(j).Month
               h_data.ng_price(i)=ng_price.ng_price(j);
            end
        end
    end
end
disp("income");      

income=0;
tot_op=0;
mc_energy=0;
mc_rrs=0;
mc_regup=0;
mc_regdn=0;
for i=1:height(h_data)
    h_data.mc(i)=((h_data.ng_price(i)/1.037)*9.750)+(10.37*0.95); %((fuel_cost)/thousand_cu_ft to m_btu) * ht_rate)+(var_o&m * location_fact)
    if h_data.total_lmp(i)>=h_data.mc(i)
        income_energy=50*h_data.total_lmp(i);
        h_data.r_e(i)=income_energy;
        mc_energy=mc_energy+(h_data.mc(i)*50);
        h_data.r_ns(i)=0;
        h_data.operation(i)=1;
    else
        as_nsr_temp=h_data.NSPIN(i)*50;
        r_rs_temp=20*h_data.total_lmp(i)+30*h_data.RRS(i);
        r_regup_temp=20*h_data.total_lmp(i)+30*h_data.REGUP(i);
        r_regdn_temp=50*h_data.total_lmp(i)+30*h_data.REGDN(i);
    
        if (max([r_rs_temp-20*h_data.mc(i),r_regup_temp-20*h_data.mc(i), r_regdn_temp-50*h_data.mc(i),as_nsr_temp])==r_rs_temp-20*h_data.mc(i) && r_rs_temp-20*h_data.mc(i)>0)
          h_data.r_rs(i)=r_rs_temp; 
          mc_rrs=mc_rrs+20*h_data.mc(i);
          h_data.r_ns(i)=0;
          h_data.operation(i)=2; 
          
        elseif(max([r_rs_temp-20*h_data.mc(i),r_regup_temp-20*h_data.mc(i), r_regdn_temp-50*h_data.mc(i),as_nsr_temp])==r_regup_temp-20*h_data.mc(i) && r_regup_temp-20*h_data.mc(i)>0)
          h_data.r_ru(i)=r_regup_temp; 
          mc_regup=mc_regup+20*h_data.mc(i);
          h_data.r_ns(i)=0;
          h_data.operation(i)=4;           
            
        elseif(max([r_rs_temp-20*h_data.mc(i),r_regup_temp-20*h_data.mc(i), r_regdn_temp-50*h_data.mc(i),as_nsr_temp])==r_regdn_temp-50*h_data.mc(i) && r_regdn_temp-50*h_data.mc(i)>0)
          h_data.r_rd(i)=r_regdn_temp; 
          mc_regdn=mc_regdn+50*h_data.mc(i);
          h_data.r_ns(i)=0;
          h_data.operation(i)=5; 
          
        else   
            h_data.r_ns(i)=as_nsr_temp;
            h_data.r_rs(i)=0;
            h_data.operation(i)=3; 
        end
 
        income_energy=0;
        h_data.r_e(i)=income_energy;
        
    end

    tot_op=tot_op+h_data.operation(i);
    
   
    h_data.income(i)=h_data.r_e(i)+h_data.r_rs(i)+h_data.r_ns(i)+h_data.r_ru(i)+h_data.r_rd(i);
    income=income+h_data.income(i);
    
end

result{y-2009}=h_data;
operation{y-2009}=tabulate(h_data.operation);
summary(s,1)=y;
summary(s,2)=income;
summary(s,3)=tot_op;
summary(s,4)=mc_energy+mc_rrs+mc_regup+mc_regdn;
summary(s,5)=sum(h_data.r_e);
summary(s,6)=sum(h_data.r_rs);
summary(s,7)=sum(h_data.r_ns);
summary(s,8)=sum(h_data.r_ru);
summary(s,9)=sum(h_data.r_rd);
summary(s,10)=mc_energy;
summary(s,11)=mc_rrs;
summary(s,12)=mc_regup;
summary(s,13)=mc_regdn;

s=s+1;
end
sum_table=array2table(summary);
sum_table.Properties.VariableNames={'Year' 'Revenue' 'Hours_Op' 'Total_MC' 'Rev_Energy' 'Rev_SR' 'Rev_NS' 'Rev_REGUP' 'Rev_REGDN' 'Energy_MC' 'SR_MC' ,'REGUP_MC' 'REGDN_MC'};

figure('Name',char(result{1,5}.node_name(3)))
for x=5:9
    t=2010+x;
subplot(1,5,x)
hold on
yyaxis left
ylabel('Clearing Price')
plot(result{1,x}.time_stamp,result{1,x}.total_lmp);
yyaxis right
ylabel('Revenue')
plot(result{1,x}.time_stamp,result{1,x}.income);
hold off
title(t)
end