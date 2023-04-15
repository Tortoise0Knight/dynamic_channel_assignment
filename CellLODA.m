classdef CellLODA < CellBase
    
    properties
        % loc_x(1,1) int16
        % loc_y(1,1) int16
        % SC (1,:) int16 = []
    end
    
    methods 
        % Constructor method
        % 初始化CellLODA时，可以空初始化, 提供x,y坐标，或提供全部3个参数
        function obj = CellLODA(loc_x, loc_y, sc)
            if nargin == 0
                super_args = {};
            elseif nargin == 2
                super_args{1} = loc_x;
                super_args{2} = loc_y;
            elseif nargin == 3
                super_args{1} = loc_x;
                super_args{2} = loc_y;
                super_args{3} = sc;
            else
                error(['Amount of parameters given for CellLODA() is ' ...
                    'incorrect, only 3 or 5 are acceptable'])
            end

            obj@CellBase(super_args{:});
        end
        % TODO: complete other operations related to Cell.

        function call_arrival(obj)
            % TODO:
        end

        function call_end(obj)
            % TODO:
        end

        % function that returns the location(1st columns are x, 2nd are
        % y) of n-tier neighbors recursively
        function tier_n_neighbor_location_array = get_tier_n_neighbor_location_array(obj, n)
                tier_n_neighbor_location_array = [];
                tier_n_inside_location_array = [];
                for x = 1:7
                    for y = 1:7
                        if abs(x-obj.Loc_x) < n+1 && abs(y-obj.Loc_y) < n+1 && abs(x+y-obj.Loc_x-obj.Loc_y) < n+1
                            tier_n_neighbor_location_array = vertcat(tier_n_neighbor_location_array, [x y]); 
                        end
                    end
                end
                for x = 1:7
                    for y = 1:7
                        if abs(x-obj.Loc_x) < n && abs(y-obj.Loc_y) < n && abs(x+y-obj.Loc_x-obj.Loc_y) < n
                            tier_n_inside_location_array = vertcat(tier_n_inside_location_array, [x y]); 
                        end
                    end
                end
                idx = ismember(tier_n_neighbor_location_array, tier_n_inside_location_array, 'rows');
                tier_n_neighbor_location_array(idx, :) = [];
        end
        
        % funtion that returns the set of channels that is not being used
        % in the 1-tier and 2-tier neighbors
        function X_list = get_X_list(obj, cell_matrix)
            X_list = 1:70;
            tier_1_neighbor_location_array = obj.get_tier_n_neighbor_location_array(1);
            tier_2_neighbor_location_array = obj.get_tier_n_neighbor_location_array(2);
            for i = 1:size(tier_1_neighbor_location_array, 1)
                [loc_x, loc_y] = tier_1_neighbor_location_array(i,:);
                idx = ismember(X_list, cell_matrix(loc_x, loc_y).SC);
                X_list(idx) = [];
            end
            for i = 1:size(tier_2_neighbor_location_array, 1)
                [loc_x, loc_y] = tier_2_neighbor_location_array(i,:);
                idx = ismember(X_list, cell_matrix(loc_x, loc_y).SC);
                X_list(idx) = [];
            end
        end

        % function that returns the usage frequency U(ci) of channel ci,
        % where U(ci) is defined as the number of 3-tier cells of sm
        % currently using channel ci
        function U_ci = get_U_ci(obj, cell_matrix, ci)
            U_ci = 0;
            tier_3_neighbor_location_array = obj.get_tier_n_neighbor_location_array(3);
            for i = 1:size(tier_3_neighbor_location_array)
                [loc_x, loc_y] = tier_3_neighbor_location_array(i,:);
                sc = cell_matrix(loc_x, loc_y).SC;
                if any(sc == ci)
                    U_ci = U_ci+1;
                end
            end
        end

        % function that Find the set of channels for which the usage
        % frequency U is maximum, and call it Cmax
        function Cmax_list = get_Cmax_list(obj, cell_matrix)
            Cmax_list=[];
            max_U = 0; 
            X_list = get_X_list(obj, cell_matrix);
            for ci = X_list
                U_ci = get_U_ci(obj, cell_matrix, ci);
                if U_ci > max_U
                    Cmax_list = [ci];
                    max_U = U_ci;
                elseif U_ci == max_U
                    Cmax_list = [Cmax_list ci];
                end
            end
        end

    end
end