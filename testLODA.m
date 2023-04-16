% variables retaled to scenario simulation defined below
sim_hours = 30; % simulation lasts for 1 hour
traffic_load_list = 100:5:200; % mean 150 calls/hour
blocking_rate_LODA_average_list = [];

 
%--------------------------------------------------------------------------
% FA simulation below
% loop over different traffic loads  
% 1. Cell Matrix creation
cell_matrix_LODA(7, 7) = CellLODA(7, 7);
for i = 1:7
    for j = 1:7
        cell_matrix_LODA(i, j) = CellLODA(i, j);
    end
end

traffic_load = 120;
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
    fprintf("%i\n", k);
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