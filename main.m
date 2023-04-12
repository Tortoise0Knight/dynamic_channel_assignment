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
sim_hours = 100; % simulation lasts for 1 hour
lambda_poisson = 150; % mean 150 calls/hour
call_arrivals = (rand(7, 7, 36000*sim_hours) < lambda_poisson/36000); %timestep is set to 0.1s 
%--------------------------------------------------------------------------
% FA simulation below
% 1. Cell Matrix creation
cell_matrix_FA(7, 7) = CellFA(7, 7, []);
for i = 1:7
    for j = 1:7
        cell_matrix_FA(i, j) = CellFA(i, j, channel_names(channel_group_map(i,j),:));
    end
end

% 2. global variables
call_arrivals_timesteps = size(call_arrivals, 3);
call_ends_FA(7, 7, 1000) = -1; % initialize the call_ends matrix
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
                        call_dur = round(exprnd(1800));
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
        foo_NB_FA_list = [foo_NB_FA_list NB_FA];
    end
end