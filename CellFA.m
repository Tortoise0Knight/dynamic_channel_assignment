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
        % 初始化CellFA时，可以提供x,y坐标及FC，或提供全部4个参数
        function obj = CellFA(loc_x, loc_y, fc, sc)
            if nargin == 3
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
            
            obj.FC = fc;
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