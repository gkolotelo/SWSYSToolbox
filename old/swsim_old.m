function simout = swsim(swsys,t,varargin)
%SWSIM Simulate time response of switched dynamical systems.
%
%   SIMOUT = swsim(SWSYS,T) simulates the time response of the switched
%   dynamical system SWSYS for the given time vector T, consisting of
%   regularly spaced time samples.
%
%   SIMOUT = swsim(SWSYS,T,X0) specifies the initial state vector X0 at time
%   T(1). X0 is set to zero when omitted.
%
%   SIMOUT = swsim(SWSYS,T,X0,U) simulates the time response of the switched
%   dynamical system SWSYS to input signal described by U. The length of the
%   input U must be the same of the time vector T. For continuous-time models,
%   choose the sampling period T(2)-T(1) small enough to accurately describe
%   the input U.
%
%   Options:
%       'i0'        Force initial value for sigma(0).
%
%       'live'      Display system state plot during simulation.
%
%       'silent'    Hide progress bar and plot.
%
%   Output:
%       simout
%          .y            Output history y(t)
%          .t            Time vector T
%          .i            Rule history sigma(t)
%          .x            System state history x(t)
%          .u            Input history u(t)
%          .sim_time     Time elapsed
%          .timestamp    Timestamp
%

%
%   swsim v0.4 26-May-2018
%   Author: Guilherme Kairalla Kolotelo
%   Copyright 2017-2018
%


% Defaults flags:
live_flag = false;
silent_flag = false;

% Auxiliary variables:
global loc
loc = 0;
t0 = t(1);
t_length = length(t);
progress_step = floor(t_length/100);

% Default values:
x0 = zeros(swsys.n_x,1);
in = zeros(t_length,swsys.n_u);
i0 = NaN;

% Allocating variables
y = zeros(t_length,swsys.n_y);
i = zeros(1,t_length);

% Process inputs and flags:
process_inputs(nargin,varargin)
check_consistency()
args = [];
if ~silent_flag
    progressbar('Running Simulation...')
    if live_flag
        args.live_fig = figure;
        for i = 1:swsys.n_x
            live_plot{i} = animatedline;
        end
    else
        args.live_fig = [];
    end
end
clanupObj = onCleanup(@() cleanupFun(args));


% Simulate
tic;
simout.timestamp = sprintf('Simulation started : %s;',datetime);

% Initial assignments
state.t = t0;
state.x = x0';
state.in = in(1,:)';
state.i = i0;
if isnan(state.i)
    state.i = swsys.rule(swsys,state);
end

    
[t,x] = ode1(@(t,x)sys_wrapper(swsys,t,x),t,x0);

% state.x = x(end,:)';
% state.t = t(end);
% state.in = in(end,:)';
% i(end) = swsys.rule(swsys,state);
% state.i = i(end);
%[~,y(end,:)] = swsys.sys(swsys,state);


% Build return object
simout.sim_time = toc();
simout.timestamp = strcat(simout.timestamp, sprintf('\nSimulation finished: %s',datetime));
simout.y = y;
simout.i = i;
simout.x = x;
simout.t = t;
simout.u = in;


function [dx,out] = sys_wrapper(swsys,time,x)
% Provides additional functionality for simulation of system swsys.
    % Set state
    
    loc = loc + 1;
    
    state.t = time;
    state.x = x;
    state.in = in(loc,:)';
    
    [dx,out] = swsys.sys(swsys,state);
    state.dx = dx;
    state.out = out;
    
    state.i = swsys.rule(swsys,state);
    
    y(loc,:) = out';
    i(loc) = state.i;
    
    if ~silent_flag
        if mod(loc,progress_step)==0
            progressbar(loc/t_length);
            if live_flag
                for k = 1:swsys.n_x
                    addpoints(live_plot{k},state.t,state.x(k));
                end
                drawnow
            end
        end
    end
end

% Old sys_wrapper
% function [dx,out] = sys_wrapper(swsys,time,x)
% % Provides additional functionality for simulation of system swsys.
%     % Set state
%     state.t = time;
%     loc = loc + 1;
%     state.x = x;
%     state.in = in(loc,:)';
%     if state.t == t0 && ~isnan(i0)
%         state.i = i0;
%     else
%         state.i = swsys.rule(swsys,state);
%     end
%     
%     [dx,out] = swsys.sys(swsys,state);
%     state.dx = dx;
%     state.out = out;
%     
%     y(loc,:) = out';
%     i(loc) = state.i;
%     
%     if ~silent_flag
%         if mod(loc,progress_step)==0
%             progressbar(loc/t_length);
%             if live_flag
%                 for k = 1:swsys.n_x
%                     addpoints(live_plot{k},state.t,state.x(k));
%                 end
%                 drawnow
%             end
%         end
%     end
% end

function process_inputs(nargs,varargs)
% Process additional inputs.
    ni = 1;
    if nargs >= 3 && isnumeric(varargs{1})
        x0 = varargs{1};
        ni = 2;
    end
    if nargs >= 4 && isnumeric(varargs{2})
        in = varargs{2};
        ni = 3;
    end
    while ni <= nargs - 2
        if ischar(varargs{ni}) 
            if strcmpi(varargs{ni},'live')
                live_flag = true;
            elseif strcmpi(varargs{ni},'silent')
                silent_flag = true;
            elseif strcmpi(varargs{ni},'i0')
                i0 = varargs{ni+1};
                ni = ni + 1;
            else
                error('Invalid syntax. No property matches the string "%s". See help section.',varargs{ni}) 
            end
        else
            error('Invalid syntax. Input arguments must be string values.') 
        end
        ni = ni + 1;
    end
end

function check_consistency()
% Checks consistency of inputs
    [m,n] = size(in);
    if n == t_length
        in = in';
    end
    if m ~= t_length
        error('Input vector U is not the same length as time vector T.')
    end
    if n ~= swsys.n_u
        error('Input vector U does not match description of system SWSYS. Input vector U provides %d channel(s), expected %d instead.',n,swsys.n_u)
    end

end

function cleanupFun(args)
% Cleanup after completion
    progressbar(1);
    try
        close(args.live_fig);
    catch
    end
end

end
