% the matrix that specify the original traffic load for each cell
traffic_load_map = ...
    [80 60 140 100 80 160 60; 
    100 60 120 60 40 100 120; 
    100 120 40 20 140 40 180;
    160 20 100 200 60 60 40;
    80 40 40 80 60 100 160;
    60 100 140 100 20 160 80;
    120 60 60 160 120 120 80];

% the matrix that specify the channel group No. for each cell
channel_group_map = ...
    [3 7 2 5 4 6 1; 
    5 4 6 1 3 7 2; 
    1 3 7 2 5 4 6;
    2 5 4 6 1 3 7;
    6 1 3 7 2 5 4;
    7 2 5 4 6 1 3;
    4 6 1 3 7 2 5];

% the matrix that specify the channel names, each row represents a group
channel_names = reshape((1:70), [10, 7]);
channel_names = permute(channel_names, [2 1]);


% variables retaled to scenario simulation defined below
sim_hours = 50; % simulation lasts for 1 hour
traffic_load_ratio_list = 1:0.1:2.5; 
traffic_load_list = zeros(7, 7, length(traffic_load_ratio_list));
for i = 1:length(traffic_load_ratio_list)
    traffic_load_list(:,:,i) = traffic_load_map * traffic_load_ratio_list(i);
end
blocking_rate_FA_average_list = [];

 
%--------------------------------------------------------------------------
% FA simulation below
% loop over different traffic loads
for traffic_load_index = 1:size(traffic_load_list, 3)
    traffic_load = traffic_load_list(:,:,traffic_load_index);
    % 1. Cell Matrix creation
    cell_matrix_FA(7, 7) = CellFA(7, 7, []);
    for i = 1:7
        for j = 1:7
            cell_matrix_FA(i, j) = CellFA(i, j, channel_names(channel_group_map(i,j),:));
        end
    end

    % 2. global variables
    call_arrivals = (rand(7, 7, 36000*sim_hours) < traffic_load/36000); %timestep is set to 0.1s
    call_arrivals_timesteps = size(call_arrivals, 3);
    call_ends_FA = zeros(7, 7, call_arrivals_timesteps+1800); % initialize the call_ends matrix
    NB_FA = 0; % blocked calls count
    NC_FA = 0; % call arrivals count
    blocking_rate_list_FA = [0]; % records the blocking rate over time
    blocking_rate_time_list_FA = [0]; % the timespots corresponsing to blocking_rate_list
    foo_NB_FA_list = [0];
    
    % 3. simulation loop
    for k = 1:call_arrivals_timesteps
        % handle call ends first
        call_ends_FA_slice = call_ends_FA(:,:,k);
        if any(any(call_ends_FA_slice)) % ignore this slice if no call ends
            for i = 1:7
                for j = 1:7
                    if call_ends_FA_slice(i, j) > 0
                        cell_matrix_FA(i,j)=cell_matrix_FA(i,j).call_end(call_ends_FA_slice(i,j));
                    end
                end
            end
        end
        % then handle call arrivals
        call_arrivals_slice = call_arrivals(:,:,k);
        if any(any(call_arrivals_slice)) % ignore this slice if no call arrival
            for i = 1:7
                for j = 1:7
                    if call_arrivals_slice(i, j)
                        [cell_matrix_FA(i,j),NB_FA,NC_FA,channel] = cell_matrix_FA(i,j).call_arrival(NB_FA,NC_FA);
                        if channel > 0 % call successfully started
                            call_dur = 1800; %min(36000, round(exprnd(1800)));
                            call_ends_FA(i,j,k+call_dur) = channel;
                        end
                    end
                end
            end
        end
        % calculate blocking rate every minutes
        if mod(k, 600) == 0
            blocking_rate_time_list_FA = [blocking_rate_time_list_FA k/600];
            blocking_rate_list_FA = [blocking_rate_list_FA NB_FA/NC_FA];
        end
    end
    blocking_rate_FA_average = mean(blocking_rate_list_FA(2000:3000));
    blocking_rate_FA_average_list = [blocking_rate_FA_average_list blocking_rate_FA_average];
    disp(["traffic load ratio:" traffic_load_ratio_list(traffic_load_index) "blocking rate:" blocking_rate_FA_average])
end