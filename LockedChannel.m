classdef LockedChannel

    properties
        channel_order int16
        locked_directions int16
        responsible_cell_location (1,2) int16
    end
    
    methods 
        % Constructor method
        % 初始化LockedChannel时，需要提供全部3个参数
        function obj = LockedChannel(varargin)
            if nargin == 3
                obj.channel_order = varargin{1};
                obj.locked_directions = varargin{2};
                obj.responsible_cell_location = varargin{3};
            else
                error(['Amount of parameters given for LockedChannel()' ...
                    ' is incorrect, only 3 is acceptable'])
            end
        end
    end
end