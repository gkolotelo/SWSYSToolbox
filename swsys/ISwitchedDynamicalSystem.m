%
%   ISwitchedDynamicalSystem v0.1 28-May-2018
%   Author: Guilherme Kairalla Kolotelo
%   Copyright 2018
%
classdef ISwitchedDynamicalSystem < handle
% Interface class for a state-space switched dynamical system

    % Abstract methods
    methods (Abstract = true)
        % Implements the equations describing the dynamics of the
        % continuous-time or discrete-time state variables.  
        % @param state Complete state information (t,x,i,u,y,p)
        % @retval dx may be dx/dt or x[k+1]
        dx = dynamics(obj,state);

        % Implements the output function
        % @param state Complete state information (t,x,i,u,y,p)
        % @retval y Output vector
        y = output(obj,state);

        % Implements the switching function
        % @param state Complete state information (t,x,i,u,y,p)
        % @retval i Active subsystem
        i = swfun(obj,state);
    end

    % Accessor methods
    methods 
        function setDT(obj)
            obj.DT = true;
        end
        
        function setName(obj,name)
            obj.name = name;
        end
        
        function setSwFunHandle(obj,handle)
            obj.swfun_h = handle;
        end

        function value = Ndim(obj)
            value = length(obj.subsystems);
        end

        function obj = addSubsystem(obj, subsys)
            if nargin < 2
                error('SwitchedSysToolBox:SwitchedDynamicalSystem:AddSubsystemError','No subsystem to add.');
            end

            checkNewSubsystemConsistency(obj,subsys);

            if obj.Ndim() == 0 % First subsystem added, set dimensions
                obj.xdim = subsys.xdim();
                obj.udim = subsys.udim();
                obj.ydim = subsys.ydim();
            end
            
            obj.subsystems{end + 1} = subsys;
        end

        function removeSubsystem(obj, index)
            if nargin < 2
                error('SwitchedSysToolBox:SwitchedDynamicalSystem:GenericError','No subsystem to remove.');
            end
            if obj.Ndim < index
                error('SwitchedSysToolBox:SwitchedDynamicalSystem:GenericError','Index out of range.');
            end
            obj.subsystems(index) = [];
            for i = 1:obj.Ndim
                obj.subsystems{i}.index = i;
            end
        end
        
    end

    % Consistency checks
    methods (Access = private)
        % Checks the dimensional consistency of the subsystem being
        % added against that of existing subsystems.
        function checkNewSubsystemConsistency(obj,subsys)
            if ~isa(subsys,'ISubsystemModel')
                error('SwitchedSysToolBox:SwitchedDynamicalSystem:TypeError','Subsystem is not a "SubsystemModel".');
            end
            if obj.Ndim() == 0
                return
            end
            if obj.xdim() ~= subsys.xdim()
                error('SwitchedSysToolBox:SwitchedDynamicalSystem:DimensionMismatch','Subsystem dimension of "x" does not match that of existing subsystems.');
            end
            if obj.udim() ~= subsys.udim()
                error('SwitchedSysToolBox:SwitchedDynamicalSystem:DimensionMismatch','Subsystem dimension of "u" does not match that of existing subsystems.');
            end
            if obj.ydim() ~= subsys.ydim()
                error('SwitchedSysToolBox:SwitchedDynamicalSystem:DimensionMismatch','Subsystem dimension of "y" does not match that of existing subsystems.');
            end
        end
    end
    
    % Display method override
    methods
        function disp(obj)
            fprintf('SwitchedDynamicalSystem:\n\n');
            if obj.Ndim() == 0
                fprintf('\nEmpty ');
            else
                fprintf('   N Subsystems:  %d\n',obj.Ndim());
                fprintf('   x dimension :  %d\n',obj.xdim());
                fprintf('   y dimension :  %d\n',obj.ydim());
                fprintf('   u dimension :  %d\n',obj.udim());
                if ~isempty(obj.swfun_h)
                    fprintf('   Assigned switching function handle:  %s\n',func2str(obj.swfun_h));
                else
                    fprintf('   No switching function handle assigned!\n');
                end
                if obj.DT
                    fprintf('\nDiscrete-time ');
                else
                    fprintf('\nContinuous-time ');
                end
            end
            fprintf('%s\n',obj.name);
            fprintf('\n');
        end
    end
    
    properties (SetAccess = private, GetAccess = public)
        % Switching function handle, if needed
        swfun_h = [];
    end

    properties (SetAccess = private, GetAccess = public)
        subsystems = {};    % Subsystems
        DT = false;             % True for discrete-time systems
        xdim = 0;           % State vector dimension
        ydim = 0;           % Output vector dimension
        udim = 0;           % Input vector dimension
        name = 'Switched Dynamical System'; % Name of switched dynamical system
    end
end