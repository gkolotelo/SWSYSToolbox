%
%   SwitchedDynamicalSystemState v0.1 28-May-2018
%   Author: Guilherme Kairalla Kolotelo
%   Copyright 2018
%
classdef SwitchedDynamicalSystemState
    
     methods
        function obj = SwitchedDynamicalSystemState(t0,x0,i0,u0,y0,p0)
            obj.t = NaN;
            obj.x = NaN;
            obj.i = NaN;
            obj.u = NaN;
            obj.y = NaN;
            obj.p = NaN;
            if nargin > 0
                obj.t = t0;
            end
            if nargin > 1
                obj.x = x0;
            end
            if nargin > 2
                obj.i = i0;
            end
            if nargin > 3
                obj.u = u0;
            end
            if nargin > 4
                obj.y = y0;
            end
            if nargin > 5
                obj.p = p0;
            end
        end
     end
    
    % System State
    properties (SetAccess = public, GetAccess = public)
        t   % Time
        x   % State vector
        i   % Active subsystem index
        u   % Input vector
        y   % Output vector
        p   % Generic parameter
    end
end