%
%   SwitchedAffineSystem v0.1 28-May-2018
%   Author: Guilherme Kairalla Kolotelo
%   Copyright 2018
%
classdef SwitchedAffineSystem < SwitchedDynamicalSystem
    
    % Constructor
    methods
        function obj = SwitchedAffineSystem(A,b,B,C,D,varargin)

            % Create empty SwitchedDynamicalSystem
            obj = obj@SwitchedDynamicalSystem(varargin{:});
            
            % Parse inputs
            if nargin >= 5 % Matrices provided
                if ~iscell(A)
                    error('SwitchedSysToolBox:SwitchedAffineSystem:InvalidSyntax','Input "A" is not a cell');
                end
            
                N = length(A);

                if ~isscalar(b) && length(b) ~= N
                    error('SwitchedSysToolBox:SwitchedAffineSystem:DimensionMismatch','"b" cell length mismatch. Expected %d elements.',N)
                end
                if ~isscalar(B) && (length(B) ~= N)
                    error('SwitchedSysToolBox:SwitchedAffineSystem:DimensionMismatch','"B" cell length mismatch. Expected %d elements.',N)
                end
                if ~isscalar(C) && (length(C) ~= N)
                    error('SwitchedSysToolBox:SwitchedAffineSystem:DimensionMismatch','"C" cell length mismatch. Expected %d elements.',N)
                end
                if ~isscalar(D) && (length(D) ~= N)
                    error('SwitchedSysToolBox:SwitchedAffineSystem:DimensionMismatch','"D" cell length mismatch. Expected %d elements.',N)
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
                    obj.addSubsystem(BasicSubsystemModel(A{i},B{i},C{i},D{i},b{i}));
                end
            elseif nargin ~= 0
                error('SwitchedSysToolBox:SwitchedAffineSystem:InvalidSyntax','Invalid syntax. See help section.');
            end

            % Set name for display
            obj.setName('Switched Affine System');

        end
    end

    % Override methods
    methods
        function dx = dynamics(obj,state)
            dx = obj.subsystems{state.i}.A*state.x + obj.subsystems{state.i}.B*state.u + obj.subsystems{state.i}.b;
        end
        
        function y = output(obj,state)
            y = obj.subsystems{state.i}.C*state.x + obj.subsystems{state.i}.D*state.u;
        end
    end

end




