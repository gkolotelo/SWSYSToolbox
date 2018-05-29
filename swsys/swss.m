function swsys = swss(varargin)
%SWSS Construct state-space model for a switched dynamical system.
%
%   SWSYS = swss(A,B,C,D,@rule) creates an object SYS representing the
%   continuous-time switched linear system with state-space model
%       dx/dt  = A_ix(t) + B_iu(t)
%       y(t)   = C_ix(t) + D_iu(t)
%   You can set D=0 to mean the zero matrix of appropriate size.
%
%   SWSYS = swss(A,b,B,C,D,@rule) creates an object SYS representing the
%   continuous-time switched affine system with state-space model
%       dx/dt  = A_ix(t) + B_iu(t)
%       y(t)   = C_ix(t) + D_iu(t)
%
%   Output:
%       swsys
%          .A       Cell containing subsystem matrices A_i
%          .B       Cell containing subsystem matrices B_i
%          .C       Cell containing subsystem matrices C_i
%          .D       Cell containing subsystem matrices D_i
%          .n_x     State vector dimension
%          .n_u     Input vector dimension
%          .n_y     Output vector dimension
%          .rule    Handle for switching function/rule rule(swsys,state)
%          .sys     Handle for system model function sys(swsys,state)
%

%
%   swss v0.3.4 25-May-2018
%   Author: Guilherme Kairalla Kolotelo
%   Copyright 2017-2018
%

% Add overload for cell of handles for behavior


if nargin == 5 % Linear
    affine = 0;
elseif nargin == 6 % Affine
    affine = 1;
    swsys.b = varargin{2};
else
    error('Invalid Syntax.')
end

swsys.A = varargin{1};
swsys.N = size(swsys.A,2);
swsys.n_x = size(swsys.A{1},1);

swsys.B = varargin{2 + affine};
if isscalar(swsys.B) && swsys.B == 0
    swsys.B = cellmat(1,swsys.N,swsys.n_x,1);
end
swsys.n_u = size(swsys.B{1},2);
swsys.C = varargin{3 + affine};
if isscalar(swsys.C) && swsys.C == 1
    swsys.C = cellmat(1,swsys.N,swsys.n_x,swsys.n_x,eye(swsys.n_x));
end
swsys.n_y = size(swsys.C{1},1);
swsys.D = varargin{4 + affine};
if isscalar(swsys.D) && swsys.D == 0
    swsys.D = cellmat(1,swsys.N,swsys.n_y,swsys.n_u);
end
swsys.rule = varargin{5 + affine};
if ~isa(swsys.rule,'function_handle')
    error('Invalid syntax.')
end

if affine
    swsys.sys = @sys_ct_affine;
else
    swsys.sys = @sys_ct_linear;
end

check_consistency()
    
% state.x
% state.dx
% state.t
% state.i
% state.in
% state.out

% System definition format:
% function state = sys(swsys,state)
%   state.dx = ...
%   state.out = ...
% end

function [dx,out] = sys_ct_linear(swsys,state)
    dx = swsys.A{state.i}*state.x + swsys.B{state.i}*state.in;
    out = swsys.C{state.i}*state.x + swsys.D{state.i}*state.in;
end

function [dx,out] = sys_ct_affine(swsys,state)
    dx = swsys.A{state.i}*state.x + swsys.B{state.i}*state.in + swsys.b{state.i};
    out = swsys.C{state.i}*state.x + swsys.D{state.i}*state.in;
end



% Auxiliary functions
function check_consistency()
    % Check whether matrices A,b,B,C,D have consistent dimensions.
    [rA,cA] = size(swsys.A{1});
    for i = 1:length(swsys.A)
        if (size(swsys.A{i},1) ~= cA) || (size(swsys.A{i},2) ~= cA)
            error('A{%d} matrix is not a square matrix.',i)
        end
    end
    
    if exist('b','var')
        if length(swsys.b) ~= swsys.N
            error('b cell length size mismatch. Expected %d elements.',swsys.N)
        end
        for i = 1:length(swsys.A)
            if (size(swsys.b{i},1) ~= rA) || (size(swsys.b{i},2) ~= 1)
                error('b{%d} vector of incorrect dimensions. Expected a vector with %d rows.',i,rA)
            end
        end
    end
    
    if length(swsys.B) ~= swsys.N
        error('B cell length size mismatch. Expected %d elements.',swsys.N)
    end
    [~,cB] = size(swsys.B{1});
    for i = 1:length(swsys.A)
        if (size(swsys.B{i},1) ~= rA) || (size(swsys.B{i},2) ~= cB)
            error('B{%d} matrix of incorrect dimensions. Expected a matrix with %d rows and %d columns.',i,rA,cB)
        end
    end
    
    if length(swsys.C) ~= swsys.N
        error('C cell length size mismatch. Expected %d elements.',swsys.N)
    end
    [rC,cC] = size(swsys.C{1});
    for i = 1:length(swsys.A)
        if (size(swsys.C{i},2) ~= rA) || (size(swsys.C{i},2) ~= cC)
            error('C{%d} matrix of incorrect dimensions. Expected a matrix with %d rows and %d columns.',i,rA,cC)
        end
    end
    
    if length(swsys.D) ~= swsys.N
        error('D cell length size mismatch. Expected %d elements.',swsys.N)
    end
    for i = 1:length(swsys.A)
        if (size(swsys.D{i},1) ~= rC) || (size(swsys.D{i},2) ~= cB)
            error('D{%d} matrix of incorrect dimensions. Expected a %d rows and %d columns.',i,rC,cB)
        end
    end
end



end