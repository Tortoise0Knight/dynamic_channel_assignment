% the matrix that specify the channel group No. for each cell
channel_group_number_for_each_cell = ...
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



