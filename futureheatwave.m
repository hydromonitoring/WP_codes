clc;
clear;

% Load lat-lon and model list
latlon = dlmread('/DATA1/arpit_data/new_lat_lon_4434.txt');
model = importdata('/DATA1/arpit_data/list_models');
scen = {'ssp126', 'ssp245', 'ssp370', 'ssp585'};



frequencysum=[];

for s=1:4 % scenario
for m=1:12   % models

    for f = 1:length(latlon)
        disp([s m f]);

        % Load Tmax data
        T1=dlmread(['/DATA2/ALL_DATA_FOR_USERS/CMIP6_models_forcing/',char(model(m)),'/historical_',char(scen(s)),'/','data_',num2str(latlon(f,1)),'_',num2str(latlon(f,2))]);
        tmax = T1(:,2);

        % load dates for the model
        datemat=dlmread(['/DATA2/ALL_DATA_FOR_USERS/CMIP6_models_forcing/',char(model(m)),'/date']);

        ALL = [datemat tmax];

        % Step 1: Tag days > 70th percentile
        out = [ALL(:,1:3), zeros(size(ALL,1),1)];
        threshold70 = prctile(ALL(:,4), 70);
        hot_idx = find(ALL(:,4) > threshold70);
        out(hot_idx,4) = ALL(hot_idx,4);

        % Step 2: Adjust values based on ±15-day windows across years
        for i = hot_idx'
            if ALL(i,1) < 1981 || ALL(i,1) > 2010
                continue;
            end

            % Find all matching dates (same month and day in 1981–2010)
            b = find(ALL(:,1) >= 1981 & ALL(:,1) <= 2010 & ...
                ALL(:,2) == ALL(i,2) & ALL(:,3) == ALL(i,3));
            if isempty(b)
                continue;
            end

            % Collect ±15-day windows across all matching dates
            bbf = [];
            for k = 1:length(b)
                idx = (b(k)-15):(b(k)+15);
                idx = idx(idx >= 1 & idx <= size(ALL,1));
                bbf = [bbf; idx(:)];
            end
            bbf = unique(bbf); % Avoid duplicate entries

            % 90th percentile from all windows
            base_90 = prctile(ALL(bbf,4), 90);
            out(i,4) = ALL(i,4) - base_90;
        end

        % Step 3: Identify heatwave sequences (consecutive positive values > 2 days)
        valid_idx = find(out(:,4) > 0);
        index_diff = [1; diff(valid_idx)];
        breaks = find(index_diff > 1);

        start_idx = [valid_idx(1); valid_idx(breaks)];
        end_idx = [valid_idx(breaks - 1); valid_idx(end)];
        durations = end_idx - start_idx + 1;

        long_events = find(durations > 2);
        p = [start_idx(long_events), end_idx(long_events), durations(long_events)];

        % Step 4: Event stats - max, mean, intensity
        for j = 1:size(p,1)
            seg = ALL(p(j,1):p(j,2), 4);
            p(j,4) = max(seg);
            p(j,5) = mean(seg);
            p(j,6) = abs(p(j,5) * p(j,3));
        end

        % Step 5: Store each event info (start, end, duration, max, mean)
        out1 = zeros(size(p,1), 9);
        for j = 1:size(p,1)
            c = ALL(p(j,1):p(j,2),:);
            out1(j,1:3) = c(1,1:3);    % Start date (y,m,d)
            out1(j,4:6) = c(end,1:3);  % End date (y,m,d)
            out1(j,7) = size(c,1);     % Duration
            out1(j,8) = max(c(:,4));   % Max
            out1(j,9) = mean(c(:,4));  % Mean
        end

        % Step 6: Year-wise frequency and duration
        years = (1981:2100)';
        freq_a = zeros(length(years),2);
        dur_a = zeros(length(years),2);

        for i = 1:length(years)
            y = years(i);
            yy_idx = find(out1(:,1) == y);
            freq_a(i,:) = [y, length(yy_idx)];
            dur_a(i,:) = [y, sum(out1(yy_idx,7))];
        end

        % Final summary: year, frequency, total duration
            fin = [freq_a dur_a(:,2)];


      %  dlmwrite(['/DATA1/arpit_data/cmip6_output/model/MPI-ESM1-2-HR/',char(scen(s)),'/data','_',num2str(latlon(f,1)),'_',num2str(latlon(f,2))],fin,' ');

    end
        frequencysum=[frequencysum,fin];
end
end