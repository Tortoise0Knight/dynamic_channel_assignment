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

        function [obj, NB, NC, channel] = call_arrival(obj, NB, NC, cell_matrix)
            NC = NC + 1;
            channel = obj.get_candidate(cell_matrix);
            if channel == -1 % an invalid channel indicates block
                NB = NB + 1;
            else
                obj.SC = [obj.SC channel];
            end
        end

        function obj = call_end(obj, channel)
            obj.SC(obj.SC==channel) = [];
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
            idx = ismember(X_list, obj.SC);
            X_list(idx) = [];
            tier_1_neighbor_location_array = obj.get_tier_n_neighbor_location_array(1);
            tier_2_neighbor_location_array = obj.get_tier_n_neighbor_location_array(2);
            for i = 1:size(tier_1_neighbor_location_array, 1)
                loc_x = tier_1_neighbor_location_array(i,1);
                loc_y = tier_1_neighbor_location_array(i,2);
                idx = ismember(X_list, cell_matrix(loc_x, loc_y).SC);
                X_list(idx) = [];
            end
            for i = 1:size(tier_2_neighbor_location_array, 1)
                loc_x = tier_2_neighbor_location_array(i,1);
                loc_y = tier_2_neighbor_location_array(i,2);
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
                loc_x = tier_3_neighbor_location_array(i,1);
                loc_y = tier_3_neighbor_location_array(i,2);
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
            X_list = obj.get_X_list(cell_matrix);
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
        
        % function that calculate the cost of using ci
        function L_ci = get_L_ci(obj, cell_matrix, ci)
            L_ci=0;
            tier_4_neighbor_location_array = obj.get_tier_n_neighbor_location_array(4);
            tier_5_neighbor_location_array = obj.get_tier_n_neighbor_location_array(5);
            for i = 1:size(tier_4_neighbor_location_array)
                loc_x = tier_4_neighbor_location_array(i,1);
                loc_y = tier_4_neighbor_location_array(i,2);
                sc = cell_matrix(loc_x, loc_y).SC;
                if any(sc == ci)
                    L_ci = L_ci+1;
                end
            end
            for i = 1:size(tier_5_neighbor_location_array)
                loc_x = tier_5_neighbor_location_array(i,1);
                loc_y = tier_5_neighbor_location_array(i,2);
                sc = cell_matrix(loc_x, loc_y).SC;
                if any(sc == ci)
                    L_ci = L_ci+2;
                end
            end
        end

        % function that find the channel in Cmax with the minimal cost L
        function candidate = get_candidate(obj, cell_matrix)
            candidate = -1;
            L_ci_min = 67; % greater than the theoreticall maximum
            Cmax_list = obj.get_Cmax_list(cell_matrix);
            for ci = Cmax_list
                L_ci = obj.get_L_ci(cell_matrix, ci);
                if L_ci < L_ci_min
                    candidate = ci;
                    L_ci_min = L_ci;
                end
            end
        end
    end
end