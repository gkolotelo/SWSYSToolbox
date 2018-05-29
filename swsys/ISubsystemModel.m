%
%   ISubsystemModel v0.1 28-May-2018
%   Author: Guilherme Kairalla Kolotelo
%   Copyright 2018
%
classdef ISubsystemModel

	properties (SetAccess = private, GetAccess = public)
		% Properties of a subsystem, dictating dynamic behavior and output.
    end
    
    % Required methods
    methods (Abstract = true)
        % Placeholder for the xdim method. Must be overrided.
        % @retval value Returns the dimension of the state vector x.
		value = xdim(obj)
        
        % Placeholder for the ydim method. Must be overrided.
        % @retval value Returns the dimension of the output vector y.
        value = ydim(obj)
        
        % Placeholder for the udim method. Must be overrided.
        % @retval value Returns the dimension of the input vector u.
        value = udim(obj)

	end

end