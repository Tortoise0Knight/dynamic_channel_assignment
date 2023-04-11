% the base Cell class for implementations with different channel strategies
classdef (Abstract) CellBase
    
    properties
        % CellBase类的属性项，包含了各种信道分配策略共通的属性
        Loc_x(1,1) int16
        Loc_y(1,1) int16
        SC (1,:) int16 = []
    end
    
    methods
        % Constructor method
        % 初始化CellBase时，可以提供x,y坐标，或提供全部3个参数
        function obj = CellBase(loc_x, loc_y, sc)
            if nargin == 2
                obj.Loc_x = loc_x;
                obj.Loc_y = loc_y;
            elseif nargin == 3
                obj.Loc_x = loc_x;
                obj.Loc_y = loc_y;
                obj.SC = sc;
            else 
                error(['Amount of parameters given for CellBase() is ' ...
                    'incorrect, only 2 or 3 are acceptable'])
            end
        end
    end

    methods (Abstract)
        % start a call
        call_start(obj)

        % end a call
        call_end(obj)
    end
end