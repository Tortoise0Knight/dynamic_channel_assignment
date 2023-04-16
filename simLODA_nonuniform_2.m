% the matrix that specify the original traffic load for each cell
traffic_load_map = ...
    [60 100 60 140 120 100 100; 
    140 140 120 80 80 80 100; 
    180 140 180 80 200 160 160;
    80 100 120 60 100 120 80;
    120 160 80 40 160 80 60;
    20 60 120 160 140 40 60;
    120 120 160 140 120 20 60];

% variables retaled to scenario simulation defined below
sim_hours = 25; % simulation lasts for 1 hour
traffic_load_ratio_list = 1:0.15:2.5;
traffic_load_list = zeros(7, 7, length(traffic_load_ratio_list));
for i = 1:length(traffic_load_ratio_list)
    traffic_load_list(:,:,i) = traffic_load_map * traffic_load_ratio_list(i);
end
blocking_rate_LODA_average_list_nonuniform_2 = [];

 
%--------------------------------------------------------------------------
% FA simulation below
% loop over different traffic loads
for traffic_load_index = 1:size(traffic_load_list, 3)
    traffic_load = traffic_load_list(:,:,traffic_load_index);
    % 1. Cell Matrix creation
    cell_matrix_LODA(7, 7) = CellLODA(7, 7);
    for i = 1:7
        for j = 1:7
            cell_matrix_LODA(i, j) = CellLODA(i, j);
        end
    end

    % 2. global variables
    call_arrivals = (rand(7, 7, 36000*sim_hours) < traffic_load/36000); %timestep is set to 0.1s
    call_arrivals_timesteps = size(call_arrivals, 3);
    call_ends_LODA = zeros(7, 7, call_arrivals_timesteps+1800); % initialize the call_ends matrix
    NB_LODA = 0; % blocked calls count
    NC_LODA = 0; % call arrivals count
    blocking_rate_list_LODA = [0]; % records the blocking rate over time
    blocking_rate_time_list_LODA = [0]; % the timespots corresponsing to blocking_rate_list
    
    % 3. simulation loop
    for k = 1:call_arrivals_timesteps
        % handle call ends first
        call_ends_LODA_slice = call_ends_LODA(:,:,k);
        if any(any(call_ends_LODA_slice)) % ignore this slice if no call ends
            for i = 1:7
                for j = 1:7
                    if call_ends_LODA_slice(i, j) > 0
                        cell_matrix_LODA(i,j)=cell_matrix_LODA(i,j).call_end(call_ends_LODA_slice(i,j));
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
                        [cell_matrix_LODA(i,j),NB_LODA,NC_LODA,channel] = cell_matrix_LODA(i,j).call_arrival(NB_LODA,NC_LODA,cell_matrix_LODA);
                        if channel > 0 % call successfully started
                            call_dur = 1800; %min(36000, round(exprnd(1800)));
                            call_ends_LODA(i,j,k+call_dur) = channel;
                        end
                    end
                end
            end
        end
        % calculate blocking rate every minutes
        if mod(k, 600) == 0
            blocking_rate_time_list_LODA = [blocking_rate_time_list_LODA k/600];
            blocking_rate_list_LODA = [blocking_rate_list_LODA NB_LODA/NC_LODA];
        end
    end
    blocking_rate_LODA_average = mean(blocking_rate_list_LODA(800:1500));
    blocking_rate_LODA_average_list_nonuniform_2 = [blocking_rate_LODA_average_list_nonuniform_2 blocking_rate_LODA_average];
    fprintf("traffic load ratio:%4.2f blocking rate:%8.6f\n", traffic_load_ratio_list(traffic_load_index), blocking_rate_LODA_average);
end