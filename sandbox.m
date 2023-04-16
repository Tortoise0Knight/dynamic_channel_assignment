% % Used to test functions or any other ideas.
% % Please delete or uncomment used codes
% foo_NB = 0;
% foo_NC = 0;
% foo_blocking_rate_time_list_FA = [];
% foo_blocking_rate_list_FA = [];
% foo_NB_FA_list = [];
% foo_exp_disctribution = makedist('Exponential', 'mu', 1800);
% 
% % test related to FA cell
%     foo_FA_cell = CellFA(3, 5, 1:3);
%     disp([foo_FA_cell.Loc_x, foo_FA_cell.Loc_y])
%     [foo_FA_cell, foo_NB, foo_NC, channel1] = foo_FA_cell.call_arrival(foo_NB, foo_NC);
%     [foo_FA_cell, foo_NB, foo_NC, channel2] = foo_FA_cell.call_arrival(foo_NB, foo_NC);
%     [foo_FA_cell, foo_NB, foo_NC, channel3] = foo_FA_cell.call_arrival(foo_NB, foo_NC);
%     [foo_FA_cell, foo_NB, foo_NC, channel4] = foo_FA_cell.call_arrival(foo_NB, foo_NC);
%     [foo_FA_cell, foo_NB, foo_NC, channel5] = foo_FA_cell.call_arrival(foo_NB, foo_NC);
%     foo_FA_cell = foo_FA_cell.call_end(channel1);
%     [foo_FA_cell, foo_NB, foo_NC, channel6] = foo_FA_cell.call_arrival(foo_NB, foo_NC);
%     foo_FA_cell = foo_FA_cell.call_end(channel3);
%     foo_FA_cell = foo_FA_cell.call_end(channel2);
%     [foo_FA_cell, foo_NB, foo_NC, channel7] = foo_FA_cell.call_arrival(foo_NB, foo_NC);

% foo_FA_cell = CellFA(1, 1, 1:10);
% foo_sim_hours = 100; % simulation lasts for 1 hour
% foo_lambda_poisson = 150; % mean 150 calls/hour
% foo_call_arrivals = (rand(1, 36000*foo_sim_hours) < foo_lambda_poisson/36000);
% foo_call_arrivals_timesteps = size(foo_call_arrivals, 2);
% foo_call_ends_FA = zeros(1, 1000000000);
% 
% for k = 1:foo_call_arrivals_timesteps
%     % handle call ends first
%     foo_call_ends_FA_slice = foo_call_ends_FA(k);
%     if foo_call_ends_FA_slice > 0
%         foo_FA_cell=foo_FA_cell.call_end(foo_call_ends_FA_slice);
%     end
%     % then handle call arrivals
%     foo_call_arrivals_slice = foo_call_arrivals(k);
%     if foo_call_arrivals_slice
%         [foo_FA_cell,foo_NB,foo_NC,channel] = foo_FA_cell.call_arrival(foo_NB,foo_NC);
%         if channel > 0 % call successfully started
%             call_dur = min(3600, round(random(foo_exp_disctribution)));% round(exprnd(1800));
%             foo_call_ends_FA(k+call_dur) = channel;
%         end
%     end
%     % calculate blocking rate every minutes
%     if mod(k, 600) == 0
%         foo_blocking_rate_time_list_FA = [foo_blocking_rate_time_list_FA k/600];
%         foo_blocking_rate_list_FA = [foo_blocking_rate_list_FA foo_NB/foo_NC];
%         foo_NB_FA_list = [foo_NB_FA_list foo_NB];
%     end
% end

%plot(foo_blocking_rate_time_list_FA, foo_blocking_rate_list_FA)

% 
% test related to LODA cell
    LODA_cell = CellLODA(1, 6, 11:20);
    disp([LODA_cell.Loc_x, LODA_cell.Loc_y])
    foo_1_neighbor=LODA_cell.get_tier_n_neighbor_location_array(1);
    foo_2_neighbor=LODA_cell.get_tier_n_neighbor_location_array(2);
% 
% % test related to BDCL cell
%     BDCL_cell = CellBDCL(3, 5, 11:20);
%     disp([BDCL_cell.Loc_x, BDCL_cell.Loc_y])
% 
% % test related to calls simulation
%     % Define the parameters
%     lambda = 8.3; % mean arrival rate
%     num_minutes = 60; % number of minutes to simulate
%     
%     % Generate the Poisson-distributed call counts
%     call_counts = poissrnd(lambda, [num_minutes, 7, 7]);
%     
%     % Plot the call counts over time
%     plot(call_counts(:,1,1))
%     xlabel('Time (minutes)')
%     ylabel('Call counts')
%     mean_calls_per_minutes = mean(call_counts(:,1,1));
%     
%     % use bernouli process to simulate poisson process of call starts
%     lambda_poisson = 150; % mean 150 calls/hour
%     sim_hours = 1; % simulation lasts for 1 hour
%     call_arrivals = (rand(7, 7, 36000*sim_hours) < lambda_poisson/36000);
%     call_arrivals_clip=call_arrivals(:,:,1:100);
%     test1 = call_arrivals(:, :, 1);

%plot(blocking_rate_time_list_LODA, blocking_rate_list_LODA)

foo_list = [1:6]









