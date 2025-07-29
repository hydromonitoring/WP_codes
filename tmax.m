clc;
clearvars;

% latlon file
latlon1=readmatrix('/source/Rajasthan_IMD_Lat_Long.xlsx');
latlon=latlon1(:,2:3);  % grid in lat lon format


% date matrix
ilu=[datetime(1951,1,1):datetime(2023,12,31)]';
datetimemat=[year(ilu) month(ilu) day(ilu)];


%% for grid wise mean annual Tmax (fig 1(a))
% load grid-wise datafile for Tmax

output=[];
for l=1:length(latlon)
    disp(l)

aa1=dlmread(['/source/data_',num2str(latlon(l,1)),'_',num2str(latlon(l,2))]);

tmax=aa1(:,2);

meantemp=mean(tmax,1);
lol=[latlon(l,1:2) meantemp];

output=[output; lol];  % output in lat lon tmax format
end



%% For slope estimation of TMAX (fig 1(b))
t7=[];
for l=1:length(latlon)
    disp(l)

tmax=dlmread(['/source/data_',num2str(latlon(l,1)),'_',num2str(latlon(l,2))]);


op=[datetimemat tmax];
year=[];
for i= 1951:2023
   
YEAR_ADRESS = find(op(:,1) == i);
yearwise_temp = op(YEAR_ADRESS,4);

yearwise_meantemp = mean(yearwise_temp(:,1));
date=[i yearwise_meantemp];
year=[year; date];

end

% senslope values for every grid 
[taub tau h sig Z S sigma sen n senplot CIlower CIupper D Dall C3]= ktaub(year, 0.05); % k-taub matlab fucntion should be in current folder
sen1=sen*73;
    t9=[latlon(l,1) latlon(l,2) h sen1];
    t7=[t7;t9]; % output in lat lon h sen format


end


%% For annual Tmax timeseries for rajasthan (fig 1(c))

area=[];
for l=1:length(latlon)
    disp(l)

tmax=dlmread(['/DATA2/ALL_DATA_FOR_USERS/imd_forcing_1951_2023/data_',num2str(latlon(l,1)),'_',num2str(latlon(l,2))]);

op=[datetimemat tmax];
year=[];
for i= 1951:2023
   
YEAR_ADRESS = find(op(:,1) == i);
yearwise_temp = op(YEAR_ADRESS,4);

yearwise_meantemp = mean(yearwise_temp(:,1));
date=[i yearwise_meantemp];
year=[year; date]; % annual tmax for each grid

end
area=[area,year(:,2)];
yeartimeseries=[year(:,1) mean(area,2)];  % output area-averageds time-series of Tmax

end

% annual Tmax anoamly
anomaly=[year(:,1) yeartimeseries(:,2)-mean(yeartimeseries(:,2))];

