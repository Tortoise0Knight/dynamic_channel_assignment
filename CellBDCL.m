classdef CellBDCL < CellBase
    
    properties
        % loc_x(1,1) int16
        % loc_y(1,1) int16
        % SC (1,:) int16 = []
        % CellBDCL类的专有属性项
        FC (1,:) int16 = []
        LC (1,:) LockedChannel = LockedChannel.empty(0,0)
        BC (1,:) int16 = [] % orderd list of borrowed channels
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
        
        function call_arrival(obj)
            % TODO:
        end

        function call_end(obj)
            % TODO:
        end
    end
end