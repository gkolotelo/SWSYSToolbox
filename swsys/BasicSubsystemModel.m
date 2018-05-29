%
%   BasicSubsystemModel v0.1 28-May-2018
%   Author: Guilherme Kairalla Kolotelo
%   Copyright 2018
%
classdef BasicSubsystemModel < ISubsystemModel
    
    % Constructor
    methods
        function obj = BasicSubsystemModel(A,B,C,D,b)
            n_x = size(A,1);
            if isscalar(B) && B == 0
                B = zeros(n_x,1);
            end
            n_u = size(B,2);
            if isscalar(C) && C == 1
                C = eye(n_x);
            end
            n_y = size(C,1);
            if isscalar(D) && D == 0
                D = zeros(n_y,n_u);
            end
            obj.A = A;
            obj.B = B;
            obj.C = C;
            obj.D = D;
            if nargin > 4
                obj.b = b;
            end
            checkSubsystemConsistency(obj)
        end
    end

	properties (SetAccess = private, GetAccess = public)
		% Properties of a subsystem, dictating dynamic behavior and output.
		A = [];
		B = [];
		C = [];
		D = [];
        b = [];
    end

    % Required methods
	methods
		function value = xdim(obj)
            value = size(obj.A,1);
        end
        function value = ydim(obj)
            value = size(obj.C,1);
        end
        function value = udim(obj)
            value = size(obj.B,2);
        end
    end
    
    % Consistency checks
    methods (Access = private)
        % Check whether matrices A,b,B,C,D have consistent dimensions.
        function checkSubsystemConsistency(obj)
            [rA,cA] = size(obj.A);
            if (size(obj.A,1) ~= cA) || (size(obj.A,2) ~= cA)
                error('A matrix is not a square matrix.')
            end
            if size(obj.b,1) ~= 0
                if (size(obj.b,1) ~= rA) || (size(obj.b,2) ~= 1)
                    error('b vector of incorrect dimensions. Expected a vector with %d rows.',rA)
                end
            end
            [~,cB] = size(obj.B);
            if (size(obj.B,1) ~= rA) || (size(obj.B,2) ~= cB)
                error('B matrix of incorrect dimensions. Expected a matrix with %d rows and %d columns.',rA,cB)
            end
            [rC,cC] = size(obj.C);
            if (size(obj.C,2) ~= rA) || (size(obj.C,2) ~= cC)
                error('C matrix of incorrect dimensions. Expected a matrix with %d rows and %d columns.',rA,cC)
            end
            if (size(obj.D,1) ~= rC) || (size(obj.D,2) ~= cB)
                error('D matrix of incorrect dimensions. Expected a %d rows and %d columns.',rC,cB)
            end
        end
    end

end