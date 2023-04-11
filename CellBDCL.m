classdef CellBDCL < CellBase
    
    properties
        % loc_x(1,1) int16
        % loc_y(1,1) int16
        % SC (1,:) int16 = []
        % CellBDCL类的专有属性项
        FC (1,:) int16 = []
        LC (1,:) LockedChannel = LockedChannel.empty(0,0)
    end
    
    methods 
        % Constructor method
        % 初始化CellBDCL时，可以提供x,y坐标及FC，或提供全部5个参数
        function obj = CellBDCL(loc_x, loc_y, fc, sc, lc)
            if nargin == 3
                super_args{1} = loc_x;
                super_args{2} = loc_y;
            elseif nargin == 5
                super_args{1} = loc_x;
                super_args{2} = loc_y;
                super_args{3} = sc;
            else
                error(['Amount of parameters given for CellBDCL() is ' ...
                    'incorrect, only 3 or 5 are acceptable'])
            end

            obj@CellBase(super_args{:});
            
            obj.FC = fc;
            if nargin == 5
                obj.LC = lc;
            end
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