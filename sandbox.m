% Used to test functions or any other ideas.
% Please delete or uncomment used codes

% test related to FA cell
    FA_cell = CellFA(3, 5, 11:20);
    disp([FA_cell.Loc_x, FA_cell.Loc_y])

% test related to LODA cell
    LODA_cell = CellLODA(3, 5, 11:20);
    disp([LODA_cell.Loc_x, LODA_cell.Loc_y])

% test related to BDCL cell
    BDCL_cell = CellBDCL(3, 5, 11:20);
    disp([BDCL_cell.Loc_x, BDCL_cell.Loc_y])

% test related to calls simulation
    % Define the parameters
    lambda = 8.3; % mean arrival rate
    num_minutes = 60; % number of minutes to simulate
    
    % Generate the Poisson-distributed call counts
    call_counts = poissrnd(lambda, [num_minutes, 7, 7]);
    
    % Plot the call counts over time
    plot(call_counts(:,1,1))
    xlabel('Time (minutes)')
    ylabel('Call counts')
    mean_calls_per_minutes = mean(call_counts(:,1,1));
    
    % use bernouli process to simulate poisson process of call starts
    lambda_poisson = 150; % mean 150 calls/hour
    sim_hours = 1; % simulation lasts for 1 hour
    call_arrivals = (rand(7, 7, 36000*sim_hours) < lambda_poisson/36000);
    call_arrivals_clip=call_arrivals(:,:,1:100);


