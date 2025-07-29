%% SPATIAL PLOT (1950-2021)

clc;
clearvars;

% Loading grid file in lat lon format
latlon=dlmread('/DATA1/arpit_data/new_lat_lon_4434.txt');

% Creating date matrix
dates = datetime(1951, 1, 1):days(1):datetime(2023, 12, 31);
datetimemat = [year(dates)', month(dates)', day(dates)'];

t7=[];


for f=1:length(latlon)
    disp([f]);
    % Loading data for specific latitude and longitude
    tmax=dlmread(['/DATA2/ALL_DATA_FOR_USERS/imd_forcing_1951_2023/data_',num2str(latlon(f,1)),'_',num2str(latlon(f,2))]);

    ALL = [datetimemat tmax];
    out=ALL;
    out(:,4)=0;
    ahh=find(ALL(:,2)>=1 & ALL(:,2)<=12 & ALL(:,4)>prctile(ALL(:,4),70));
    out(ahh,4)=ALL(ahh,4);
    lo=find(out(:,4)>0);
    for i=lo'
        b = find(ALL(:,1)>=1981 & ALL(:,1)<=2010 & ALL(:,2)==ALL(i,2) & ALL(:,3)==ALL(i,3));
        bbf1=vec_linspace(b-15,b+15,31);
        bbf=bbf1(:);
        a = prctile(ALL(bbf,4),90);
        out(i,4)=ALL(i,4)-a;
    end

    clm=4;

    x=out;
    data_negative_index = find( x(:,clm)>0);
    index_derivative = [1; diff(data_negative_index);];
    step_change_point = find(index_derivative > 1);

    negative_begin_index = [data_negative_index(1); data_negative_index(step_change_point);];
    negative_end_index = [data_negative_index(step_change_point-1);data_negative_index(end);];

    index_vector = [1:length(x(:,clm))]';

    n = length(negative_begin_index);
    k = zeros(n, 4);  % preallocate

    for i = 1:n
        start_idx = negative_begin_index(i);
        end_idx = negative_end_index(i);
        data_segment = out(start_idx:end_idx, 4);
        mean_val = mean(data_segment);
        row_count = end_idx - start_idx + 1;

        k(i, [1 2 3 6]) = [start_idx, end_idx, row_count, mean_val.*row_count];
    end

    m = find(k(:,3)>2);
    p = k(m,:);

    for j=1:size(p,1)
        p(j,4)=max(ALL(p(j,1):p(j,2),clm));
        p(j,5)=mean(ALL(p(j,1):p(j,2),clm));

    end

    p1 = p;

    out1 =[];
    for j=1: size(p1,1)
        c=[];
        c=ALL(p1(j,1):p1(j,2),:);
        out1(j,1)=c(1,1);
        out1(j,2)=c(1,2);
        out1(j,3)=c(1,3);
        out1(j,4)=c(end,1);
        out1(j,5)=c(end,2);
        out1(j,6)=c(end,3);
        out1(j,7)=length(c(:,4));
        out1(j,8)=max(c(:,4));
        out1(j,9)=mean(c(:,4));
        out1(j,10)=p(j,6);

        fin=find(out1(:,1)>=1951 & out1(:,1)<=2024 );
        final=out1(fin,:);
    end

    %% only for seperate freq/duration
    if isempty(out1)
        latlon(f,3:8)=[NaN NaN NaN NaN NaN NaN];
    else
        n=1;
        freq_a=[];
        duration_a=[];
        severity_a=[];

        for yy=1951:2023
            aa=find(out1(:,1)==yy);
            freq_a(n,1)=yy;
            freq_a(n,2)=(length(aa));
            duration_a(n,1)=yy;
            duration_a(n,2)=sum(out1(aa,7));

            n=n+1;

        end

        [taub tau h sig Z S sigma sen n senplot CIlower CIupper D Dall C3]= ktaub(freq_a, 0.05); % change to freq_a for frequency and duration_a for duration
        sen1=sen*73;       % sen value for 73 year (1951-2023)
        t9=[latlon(f,1) latlon(f,2) h sen1];
        t7=[t7;t9];        % final output in [lat lon h senlope] format


      %  dlmwrite(['sourcetarget/model(m)/',char(scen(s)),'/data','_',num2str(latlon(f,1)),'_',num2str(latlon(f,2))],t7,' ');


    end
end




