classdef CellBDCL < CellBase
    
    properties
        % loc_x(1,1) int16
        % loc_y(1,1) int16
        % SC (1,:) int16 = []
        % CellBDCL类的专有属性项
        FC (1,:) int16 = []
        LC (1,:) LockedChannel = LockedChannel.empty(0,0)
        BC (:,2) int16 = [] % orderd list of borrowed channels and borrow direction
    end
    
    methods 
        % Constructor method
        % 初始化CellBDCL时，可以空初始化, 提供x,y坐标及FC，或提供全部6个参数
        function obj = CellBDCL(loc_x, loc_y, fc, sc, lc, bc)
            if nargin == 0
                super_args = {};
            elseif nargin == 3
                super_args{1} = loc_x;
                super_args{2} = loc_y;
            elseif nargin == 6
                super_args{1} = loc_x;
                super_args{2} = loc_y;
                super_args{3} = sc;
            else
                error(['Amount of parameters given for CellBDCL() is ' ...
                    'incorrect, only 3 or 6 are acceptable'])
            end

            obj@CellBase(super_args{:});
            if nargin ~= 0
                obj.FC = fc;
            end
            if nargin == 6
                obj.LC = lc;
                obj.BC = bc;
            end
        end
        % TODO: complete other operations related to Cell.

%----------1st Layer Methods-----------------------------------------------        
        function [obj, NB, NC, channel, cell_matrix] = call_arrival(obj, NB, NC, cell_matrix)
            NC = NC + 1;
            if isempty(obj.FC)
                [obj, channel, cell_matrix] = obj.get_borrowed_channel(cell_matrix);
            else
                channel = obj.FC(1);
                obj.SC = sort([obj.SC channel]);
                obj.FC(1) = [];
            end
            if channel == -1 % an invalid channel indicates block
                NB = NB + 1;
            end
        end

        function [obj, cell_matrix] = call_end(obj, channel, cell_matrix)
            [obj, cell_matrix] = channel_reallocation(obj, channel, cell_matrix);
            if ismember(obj.SC, channel)
                obj.SC(obj.SC==channel) = [];
                obj.FC = sort([obj.FC channel]);
            else
                idx = find(obj.BC(:,1)==channel);
                direction = obj.BC(idx, 2);
                cell_matrix = obj.release_borrowed_channel(channel, direction, cell_matrix);
            end
        end

%----------2nd Layer Methods-----------------------------------------------     
        % function that attempts to borrow a channel from neighbors
        function [obj, channel, cell_matrix] = get_borrowed_channel(obj, cell_matrix)
            X_list = obj.get_X_list(cell_matrix);
            if isempty(X_list)
                channel = -1;
            else 
                Y_list = obj.get_Y_list(cell_matrix, X_list);
                if isempty(Y_list)
                    channel = -1;
                else
                    [channel, direction] = CellBDCL.get_candidate(Y_list);
                    obj.BC(end+1,:) = [channel, direction];
                    obj.BC = sortrows(obj.BC);
                    cell_matrix = obj.lock_channels(channel, direction, cell_matrix);
                end
            end
        end

%----------3rd Layer Methods-----------------------------------------------
        % function that return the channel set X which contains the free
        % and not-in-block-direction channels in the neighborhood that can
        % be potentially borrowed
        function X_list = get_X_list(obj, cell_matrix)
            X_list = []; % n*3 matrix, each row: direction, number of free channels, channel name
            for direction = 1:6
                opposite_direction = mod(direction+3, 6);
                [loc_x, loc_y] = obj.direction_to_coord(direction);
                if (loc_x>=1 && loc_x<=7) && (loc_y>=1 && loc_y<=7)
                    neighbor = cell_matrix(loc_x, loc_y);
                    fc_count = length(neighbor.FC);
                    for locked_channel = neighbor.LC
                        if ~ismember(locked_channel.locked_directions, opposite_direction)
                            fc_count = fc_count+1;
                        end
                    end
                    if fc_count~=0
                        for channel = neighbor.FC
                            X_list(end+1,:) = [direction fc_count channel];
                        end
                        for locked_channel = neighbor.LC
                            if ~ismember(locked_channel.locked_directions, opposite_direction)
                                X_list(end+1,:) = [direction fc_count locked_channel];
                            end
                        end 
                    end
                else
                    continue
                end
            end
        end

        % function that returns the channel set Y which is a subset of set X
        % that do not interfere cochannel cells
        function Y_list = get_Y_list(obj, cell_matrix, X_list)
            Y_list = []; % n*3 matrix, each row: direction, number of free channels, channel name
            for i = 1:size(X_list,1)
                [direction, fc_count, channel] = X_list(i,:); 
                mat_locations = obj.direction_to_2_cochannel_coord(direction);
                cochannel_cell_1 = cell_matrix(mat_locations(1,1), mat_locations(1,2));
                cochannel_cell_2 = cell_matrix(mat_locations(2,1), mat_locations(2,2));
                if ismember(cochannel_cell_1.FC, channel) && ismember(cochannel_cell_2.FC, channel)
                    Y_list(end+1,:) = [direction, fc_count, channel];
                elseif ~obj.within_interference_distance(cochannel_cell_1, channel) && ~obj.within_interference_distance(cochannel_cell_2, channel)
                    Y_list(end+1,:) = [direction, fc_count, channel];
                end
            end
        end
        
        % function that locks the borrowed channel from neighbor and its 2
        % cochannel cells
        function cell_matrix = lock_channels(obj, channel, direction, cell_matrix)
            [loc_x, loc_y] = obj.direction_to_coord(direction);
            cell_matrix(loc_x, loc_y).FC(cell_matrix(loc_x, loc_y).FC==channel) = [];
            cell_matrix(loc_x, loc_y) = cell_matrix(loc_x, loc_y).add_locked_channel(channel, [1:6], [obj.Loc_x obj.Loc_y]);
            mat_locations = obj.direction_to_2_cochannel_coord(direction);
            for i = [1 2]
                loc_x = mat_locations(i,1);
                loc_y = mat_locations(i,2);
                if (loc_x>=1 && loc_x<=7) && (loc_y>=1 && loc_y<=7)
                    cell_matrix(loc_x, loc_y).FC(cell_matrix(loc_x, loc_y).FC==channel) = [];
                    switch direction
                        case 1
                            if i==1
                                cell_matrix(loc_x, loc_y) = cell_matrix(loc_x, loc_y).add_locked_channel(channel, [1,2,5,6], [obj.Loc_x,obj.Loc_y]);
                            else
                                cell_matrix(loc_x, loc_y) = cell_matrix(loc_x, loc_y).add_locked_channel(channel, [1,2,3], [obj.Loc_x,obj.Loc_y]);
                            end
                        case 2
                            if i==1
                                cell_matrix(loc_x, loc_y) = cell_matrix(loc_x, loc_y).add_locked_channel(channel, [1,2,6], [obj.Loc_x,obj.Loc_y]);
                            else
                                cell_matrix(loc_x, loc_y) = cell_matrix(loc_x, loc_y).add_locked_channel(channel, [1,2,3,4], [obj.Loc_x,obj.Loc_y]);
                            end
                        case 3
                            if i==1
                                cell_matrix(loc_x, loc_y) = cell_matrix(loc_x, loc_y).add_locked_channel(channel, [1,2,3], [obj.Loc_x,obj.Loc_y]);
                            else
                                cell_matrix(loc_x, loc_y) = cell_matrix(loc_x, loc_y).add_locked_channel(channel, [2,3,4,5], [obj.Loc_x,obj.Loc_y]);
                            end
                        case 4
                            if i==1
                                cell_matrix(loc_x, loc_y) = cell_matrix(loc_x, loc_y).add_locked_channel(channel, [2,3,4], [obj.Loc_x,obj.Loc_y]);
                            else
                                cell_matrix(loc_x, loc_y) = cell_matrix(loc_x, loc_y).add_locked_channel(channel, [3,4,5,6], [obj.Loc_x,obj.Loc_y]);
                            end
                        case 5
                            if i==1
                                cell_matrix(loc_x, loc_y) = cell_matrix(loc_x, loc_y).add_locked_channel(channel, [3,4,5,6], [obj.Loc_x,obj.Loc_y]);
                            else
                                cell_matrix(loc_x, loc_y) = cell_matrix(loc_x, loc_y).add_locked_channel(channel, [1,5,6], [obj.Loc_x,obj.Loc_y]);
                            end
                        case 6
                            if i==1
                                cell_matrix(loc_x, loc_y) = cell_matrix(loc_x, loc_y).add_locked_channel(channel, [4,5,6], [obj.Loc_x,obj.Loc_y]);
                            else
                                cell_matrix(loc_x, loc_y) = cell_matrix(loc_x, loc_y).add_locked_channel(channel, [1,2,5,6], [obj.Loc_x,obj.Loc_y]);
                            end
                    end
                end
            end
        end
%----------4th Layer Methods-----------------------------------------------
        % function that return the coordinates of neighbor in the given
        % direction
        function [loc_x, loc_y] = direction_to_coord(obj, direction)
            switch direction
                case 1
                    loc_x = obj.Loc_x - 1;
                    loc_y = obj.Loc_y + 1;
                case 2
                    loc_x = obj.Loc_x;
                    loc_y = obj.Loc_y + 1;
                case 3
                    loc_x = obj.Loc_x + 1;
                    loc_y = obj.Loc_y;
                case 4
                    loc_x = obj.Loc_x + 1;
                    loc_y = obj.Loc_y - 1;
                case 5
                    loc_x = obj.Loc_x;
                    loc_y = obj.Loc_y - 1;
                case 6
                    loc_x = obj.Loc_x - 1;
                    loc_y = obj.Loc_y;
                otherwise
                    error("location must be 1-6");
            end
        end
        
        % function that return the coordinates of two cochannel cells
        % according to the borrowing direction
        function mat_locations = direction_to_2_cochannel_coord(obj, direction)
            mat_locations = zeros(2);
            switch direction
                case 1
                    mat_locations(1,1)=obj.Loc_x+2;
                    mat_locations(1,2)=obj.Loc_y-1;
                    mat_locations(2,1)=obj.Loc_x;
                    mat_locations(2,2)=obj.Loc_y-2;
                case 2
                    mat_locations(1,1)=obj.Loc_x+2;
                    mat_locations(1,2)=obj.Loc_y-2;
                    mat_locations(2,1)=obj.Loc_x-1;
                    mat_locations(2,2)=obj.Loc_y-1;
                case 3
                    mat_locations(1,1)=obj.Loc_x;
                    mat_locations(1,2)=obj.Loc_y-2;
                    mat_locations(2,1)=obj.Loc_x-2;
                    mat_locations(2,2)=obj.Loc_y+1;
                case 4
                    mat_locations(1,1)=obj.Loc_x-2;
                    mat_locations(1,2)=obj.Loc_y;
                    mat_locations(2,1)=obj.Loc_x-1;
                    mat_locations(2,2)=obj.Loc_y+2;
                case 5
                    mat_locations(1,1)=obj.Loc_x-1;
                    mat_locations(1,2)=obj.Loc_y+2;
                    mat_locations(2,1)=obj.Loc_x+2;
                    mat_locations(2,2)=obj.Loc_y;
                case 6
                    mat_locations(1,1)=obj.Loc_x;
                    mat_locations(1,2)=obj.Loc_y+2;
                    mat_locations(2,1)=obj.Loc_x+2;
                    mat_locations(2,2)=obj.Loc_y-1;
                otherwise
                    error("location must be 1~6");
            end
        end
        
        % function that returns a boolean value that indicates if the
        % locking cell is within the interference distance of cell P
        function tf = within_interference_distance(obj, Cell, channel)
           tf = false;
           for locked_channel = Cell.LC
               if locked_channel.channel_order == channel
                    x = locked_channel.responsible_cell_location(1,1);
                    y = locked_channel.responsible_cell_location(1,2);
                    if abs(x-obj.Loc_x) < 3 && abs(y-obj.Loc_y) < 3 && abs(x+y-obj.Loc_x-obj.Loc_y) < 3
                        tf = true;
                    end
               end
           end
        end
        
        % function that adds an LockedChannel object to LC list and sort
        % the list by channel order
        function obj = add_locked_channel(obj, channel, locked_directions, responsible_cell_location)
            new_locked_channel = LockedChannel(channel, locked_directions, responsible_cell_location);
            obj.LC(end+1) = new_locked_channel;
            idx = sort([obj.LC.channel_order]);
            obj.LC = obj.LC(idx);
        end

    end

    methods (Static)
        % function that returns the final candidate channel which is the
        % last ordered channel from the cell with the maximum number of
        % free channels
        function [channel, direction] = get_candidate(Y_list)
            Y_list = sortrows(Y_list, [2 3]);
            channel = Y_list(end, 2);
            direction = Y_list(end, 1);
        end
    end
end