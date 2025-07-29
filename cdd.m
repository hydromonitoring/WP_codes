clc;
clearvars;

% latlon file
latlon1=readmatrix('DATA1/arpit_data/Rajasthan_IMD_Lat_Long.xlsx');
latlon=latlon1(:,2:3);  % grid in [lat lon] format


% date matrix
ilu=[datetime(1951,1,1):datetime(2023,12,31)]';
datetimemat=[year(ilu) month(ilu) day(ilu)];


%% for grid wise mean annual CDD (fig 1(a))
% load grid-wise datafile for Tmax

output=[];
for l=1:length(latlon)
    disp(l)

aa1=dlmread(['/DATA2/ALL_DATA_FOR_USERS/imd_forcing_1951_2023/data_',num2str(latlon(l,1)),'_',num2str(latlon(l,2))]); % aa1 contains tmax & tmin in column 2 and 3

cdd= mean(aa1(:,2:3),2)-18; % 18 degree is the base temperature

sumtemp=sum(cdd,1);
lol=[latlon(l,1:2) sumtemp./73];

output=[output; lol];  % output in [lat lon CDD] format
end

% median
medi=median(output(:,3))


%% For slope estimation of CDD (fig 1(b))
t7=[];

for l=1:length(latlon)
    disp(l)

aa1=dlmread(['/DATA2/ALL_DATA_FOR_USERS/imd_forcing_1951_2023/data_',num2str(latlon(l,1)),'_',num2str(latlon(l,2))]);

cdd= mean(aa1(:,2:3),2)-18;


op=[datetimemat cdd];
year=[];
for i= 1951:2023
   
YEAR_ADRESS = find(op(:,1) == i);
yearwise_temp = op(YEAR_ADRESS,4);

yearwise_meantemp = sum(yearwise_temp(:,1));
date=[i yearwise_meantemp];
year=[year; date];

end

% senslope values for every grid 
[taub tau h sig Z S sigma sen n senplot CIlower CIupper D Dall C3]= ktaub(year, 0.05); % k-taub matlab fucntion should be in current folder
sen1=sen*73;
    t9=[latlon(l,1) latlon(l,2) h sen1];
    t7=[t7;t9]; % output in [lat lon h sen] format


end

%median
medi=median(t7(:,4))

%% For annual CDD timeseries for rajasthan (fig 1(c))

area=[];
for l=1:length(latlon)
    disp(l)

aa1=dlmread(['/DATA2/ALL_DATA_FOR_USERS/imd_forcing_1951_2023/data_',num2str(latlon(l,1)),'_',num2str(latlon(l,2))]);

cdd= mean(aa1(:,2:3),2)-18;


op=[datetimemat cdd];
year=[];
for i= 1951:2023
   
YEAR_ADRESS = find(op(:,1) == i);
yearwise_temp = op(YEAR_ADRESS,4);

yearwise_meantemp = sum(yearwise_temp(:,1));
date=[i yearwise_meantemp];
year=[year; date];

end

area=[area,year(:,2)];
yeartimeseries=[year(:,1) mean(area,2)];  % output area-averaged time-series of CDD

end

% annual CDD anoamly
anomaly=[year(:,1) yeartimeseries(:,2)-mean(yeartimeseries(:,2),1)];

maxi=min(anomaly(:,2))
