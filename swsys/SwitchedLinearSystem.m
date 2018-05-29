%
%   SwitchedLinearSystem v0.1 29-May-2018
%   Author: Guilherme Kairalla Kolotelo
%   Copyright 2018
%
classdef SwitchedLinearSystem < SwitchedDynamicalSystem
    
    % Constructor
    methods
        function obj = SwitchedLinearSystem(A,B,C,D,varargin)

            % Create empty SwitchedDynamicalSystem
            obj = obj@SwitchedDynamicalSystem(varargin{:});
            
            % Parse inputs
            if nargin >= 4 % Matrices provided
                if ~iscell(A)
                    error('SwitchedSysToolBox:SwitchedLinearSystem:InvalidSyntax','Input "A" is not a cell');
                end
            
                N = length(A);

                if ~isscalar(B) && (length(B) ~= N)
                    error('SwitchedSysToolBox:SwitchedLinearSystem:DimensionMismatch','"B" cell length mismatch. Expected %d elements.',N)
                end
                if ~isscalar(C) && (length(C) ~= N)
                    error('SwitchedSysToolBox:SwitchedLinearSystem:DimensionMismatch','"C" cell length mismatch. Expected %d elements.',N)
                end
                if ~isscalar(D) && (length(D) ~= N)
                    error('SwitchedSysToolBox:SwitchedLinearSystem:DimensionMismatch','"D" cell length mismatch. Expected %d elements.',N)
                end
                if isscalar(B)
                    B = cellmat(1,N,1,1,0);
                end
                if isscalar(C)
                    C = cellmat(1,N,1,1,1);
                end
                if isscalar(D)
                    D = cellmat(1,N,1,1,0);
                end
                % Add subsystems to model
                for i = 1:N
                    obj.addSubsystem(BasicSubsystemModel(A{i},B{i},C{i},D{i}));
                end
            elseif nargin ~= 0
                error('SwitchedSysToolBox:SwitchedLinearSystem:InvalidSyntax','Invalid syntax. See help section.');
            end

            % Set name for display
            obj.setName('Switched Linear System');

        end
    end

    % Override methods
    methods
        function dx = dynamics(obj,state)
            dx = obj.subsystems{state.i}.A*state.x + obj.subsystems{state.i}.B*state.u;
        end
        
        function y = output(obj,state)
            y = obj.subsystems{state.i}.C*state.x + obj.subsystems{state.i}.D*state.u;
        end
    end
end