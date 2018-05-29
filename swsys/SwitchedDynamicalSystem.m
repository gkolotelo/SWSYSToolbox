%
%   SwitchedDynamicalSystem v0.1 28-May-2018
%   Author: Guilherme Kairalla Kolotelo
%   Copyright 2018
%
classdef SwitchedDynamicalSystem < ISwitchedDynamicalSystem
% Class for a state-space switched dynamical system

    
    % Constructor
    methods
        function obj = SwitchedDynamicalSystem(varargin)            
            ni = 1;
            while ni <= nargin
                if ischar(varargin{ni}) 
                    if strcmpi(varargin{ni},'DT')
                        obj.setDT();
                    else
                        error('SwitchedSysToolBox:SwitchedDynamicalSystem:InvalidSyntax','Invalid syntax. No property matches "%s". See help section.',varargin{ni})
                    end
                elseif iscell(varargin{ni})
                    for i = 1:length(varargin{ni})
                        obj.addSubsystem(varargin{ni}{i});
                    end
                elseif isa(varargin{ni},'function_handle')
                    obj.setSwFunHandle(varargin{ni});
                else
                    error('SwitchedSysToolBox:SwitchedDynamicalSystem:InvalidSyntax','Invalid syntax. See help section.')
                end
                ni = ni + 1;
            end
        end
    end

    % Not implemented methods
    methods
        function dx = dynamics(obj,state)
            % Placeholder for the dynamics method. Must be overloaded.
            error('SwitchedSysToolBox:SwitchedDynamicalSystem:NotImplementedMethod','"dynamics" method must be implemented.');
        end
        
        function y = output(obj,state)
            % Placeholder for the output method. Must be overloaded.
            error('SwitchedSysToolBox:SwitchedDynamicalSystem:NotImplementedMethod','"output" method must be implemented.');
        end

        function i = swfun(obj,state)
            i = obj.swfun_h(obj,state);
        end
    end
    
    
    
    
    
    

%     accessors
        %search_convex_combination(A,b)
%       has stable convex combination?

%       simulate

%       size


end






