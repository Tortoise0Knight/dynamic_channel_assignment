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

        function call_end(obj)
            % TODO:
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
                    [channel, direction] = obj.get_candidate(Y_list);
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
        function X_list = get_X_list(obj, cell_matrix);
            X_list = []; % n*3 matrix, each row: direction, number of free channels, channel name
            % TODO: 
        end

        % function that return the channel set Y which is a subset of set X
        % that do not interfere cochannel cells
        function Y_list = get_Y_list(obj, cell_matrix, X_list);
            Y_list = []; % n*3 matrix, each row: direction, number of free channels, channel name
            % TODO: 
        end

        function [channel, direction] = get_candidate(obj, Y_list)
            % TODO:
        end
        
        function lock_channels(obj, channel, direction, cell_matrix)
            % TODO:
        end
    end
end