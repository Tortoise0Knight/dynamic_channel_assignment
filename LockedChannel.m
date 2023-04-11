classdef LockedChannel

    properties
        channel_order (1,1) int16
        locked_directions (1,:) int16
        responsible_cell_location (1,2) int16
    end
    
    methods 
        % Constructor method
        % 初始化LockedChannel时，可只提供channel_order(BCO)或提供全部3个参数(BDCL)
        function obj = LockedChannel(varargin)
            if nargin ==1
                obj.channel_order = varargin{1};
            elseif nargin == 3
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