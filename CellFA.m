classdef CellFA < CellBase
    
    properties
        % loc_x(1,1) int16
        % loc_y(1,1) int16
        % SC (1,:) int16 = []
        % CellFA类的专有属性项
        FC (1,:) int16 = []
    end
    
    methods 
        % Constructor method
        % 初始化CellFA时，可以空初始化, 提供x,y坐标及FC，或提供全部4个参数
        function obj = CellFA(loc_x, loc_y, fc, sc)
            if nargin == 0
                super_args = {};
            elseif nargin == 3
                super_args{1} = loc_x;
                super_args{2} = loc_y;
            elseif nargin == 4
                super_args{1} = loc_x;
                super_args{2} = loc_y;
                super_args{3} = sc;
            else
                error(['Amount of parameters given for CellFA() is ' ...
                    'incorrect, only 3 or 4 are acceptable'])
            end
            obj@CellBase(super_args{:});
            if nargin ~= 0
                obj.FC = fc;
            end
        end
        
        function [obj, NB, NC, channel] = call_arrival(obj, NB, NC)
            NC = NC + 1;
            if isempty(obj.FC)
                NB = NB + 1;
                channel = -1; % an invalid channel indicates block
            else
                channel = obj.FC(end);
                obj.SC = [obj.SC channel];
                obj.FC(end) = [];
            end
        end

        function obj = call_end(obj, channel)
            obj.SC(obj.SC==channel) = [];
            obj.FC = [obj.FC channel];
        end
    end
end