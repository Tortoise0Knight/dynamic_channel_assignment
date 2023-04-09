classdef Cell
    
    properties
        % Cell类的属性项，默认值是信道全部空闲的情况
        loc_x(1,1) int16
        loc_y(1,1) int16
        FC = 1:10
        SC (1,:) int16 = []
        LC (1,:) LockedChannel = LockedChannel.empty(0,0)
    end
    
    methods 
        % Constructor method
        % 初始化Cell时，可以只提供x及y坐标2个参数，也可以提供全部5个参数
        function obj = Cell(varargin)
            if nargin == 2
                obj.loc_x = varargin{1};
                obj.loc_y = varargin{2};
            elseif nargin == 5
                obj.loc_x = varargin{1};
                obj.loc_y = varargin{2};
                obj.FC = varargin{3};
                obj.SC = varargin{4};
                obj.LC = varargin{5};
            else 
                error(['Amount of parameters given for Cell() is ... ' ...
                    'incorrect, only 2 or 5 are acceptable'])
            end
        end
        % TODO: complete other operations related to Cell.

    end
end