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
sim_hours = 1; % simulation lasts for 1 hour
lambda_poisson = 150; % mean 150 calls/hour
call_arrivals = (rand(7, 7, 36000*sim_hours) < lambda_poisson/36000); %timestep is set to 0.1s

% FA simulation below
cell_matrix_FA(7, 7) = CellFA(7, 7, []);
for i = 1:7
    for j = 1:7
        cell_matrix_FA(i, j) = CellFA(i, j, channel_names(channel_group_map(i,j),:));
    end
end


