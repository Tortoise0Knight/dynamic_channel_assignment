% the matrix that specify the original traffic load for each cell
traffic_load_map = ...
    [80 60 140 100 80 160 60; 
    100 60 120 60 40 100 120; 
    100 120 40 20 140 40 180;
    160 20 100 200 60 60 40;
    80 40 40 80 60 100 160;
    60 100 140 100 20 160 80;
    120 60 60 160 120 120 80];

% variables retaled to scenario simulation defined below
sim_hours = 25; % simulation lasts for 1 hour
traffic_load_ratio_list = 1:0.15:2.5;
traffic_load_list = zeros(7, 7, length(traffic_load_ratio_list));
for i = 1:length(traffic_load_ratio_list)
    traffic_load_list(:,:,i) = traffic_load_map * traffic_load_ratio_list(i);
end
blocking_rate_BDCL_average_list_nonuniform_1 = [];

 
%--------------------------------------------------------------------------
% FA simulation below
% loop over different traffic loads
for traffic_load_index = 1:size(traffic_load_list, 3)
    traffic_load = traffic_load_list(:,:,traffic_load_index);
    % 1. Cell Matrix creation
    cell_matrix_BDCL(7, 7) = CellBDCL(7, 7);
    for i = 1:7
        for j = 1:7
            cell_matrix_BDCL(i, j) = CellBDCL(i, j);
        end
    end

    % 2. global variables
    call_arrivals = (rand(7, 7, 36000*sim_hours) < traffic_load/36000); %timestep is set to 0.1s
    call_arrivals_timesteps = size(call_arrivals, 3);
    call_ends_BDCL = zeros(7, 7, call_arrivals_timesteps+1800); % initialize the call_ends matrix
    NB_BDCL = 0; % blocked calls count
    NC_BDCL = 0; % call arrivals count
    blocking_rate_list_BDCL = [0]; % records the blocking rate over time
    blocking_rate_time_list_BDCL = [0]; % the timespots corresponsing to blocking_rate_list
    
    % 3. simulation loop
    for k = 1:call_arrivals_timesteps
        % handle call ends first
        call_ends_BDCL_slice = call_ends_BDCL(:,:,k);
        if any(any(call_ends_BDCL_slice)) % ignore this slice if no call ends
            for i = 1:7
                for j = 1:7
                    if call_ends_BDCL_slice(i, j) > 0
                        cell_matrix_BDCL(i,j)=cell_matrix_BDCL(i,j).call_end(call_ends_BDCL_slice(i,j));
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
                        [cell_matrix_BDCL(i,j),NB_BDCL,NC_BDCL,channel] = cell_matrix_BDCL(i,j).call_arrival(NB_BDCL,NC_BDCL,cell_matrix_BDCL);
                        if channel > 0 % call successfully started
                            call_dur = 1800; %min(36000, round(exprnd(1800)));
                            call_ends_BDCL(i,j,k+call_dur) = channel;
                        end
                    end
                end
            end
        end
        % calculate blocking rate every minutes
        if mod(k, 600) == 0
            blocking_rate_time_list_BDCL = [blocking_rate_time_list_BDCL k/600];
            blocking_rate_list_BDCL = [blocking_rate_list_BDCL NB_BDCL/NC_BDCL];
        end
    end
    blocking_rate_BDCL_average = mean(blocking_rate_list_BDCL(800:1500));
    blocking_rate_BDCL_average_list_nonuniform_1 = [blocking_rate_BDCL_average_list_nonuniform_1 blocking_rate_BDCL_average];
    fprintf("traffic load ratio:%4.2f blocking rate:%8.6f\n", traffic_load_ratio_list(traffic_load_index), blocking_rate_BDCL_average);
end