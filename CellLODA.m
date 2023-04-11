classdef CellLODA < CellBase
    
    properties
        % loc_x(1,1) int16
        % loc_y(1,1) int16
        % SC (1,:) int16 = []
    end
    
    methods 
        % Constructor method
        % 初始化CellLODA时，可以提供x,y坐标，或提供全部3个参数
        function obj = CellLODA(loc_x, loc_y, sc)
            if nargin == 2
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

        function call_start(obj)
            % TODO:
        end

        function call_end(obj)
            % TODO:
        end
        
    end
end