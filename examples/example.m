%% Definition
clc;clear all;close all;

A{1} = [4 -5  ;6 -9];
A{2} = [-6 -10 ; -7  -8];
b{1} = [-2 -10]';
b{2} = [-5 -7]';
lambda = 0.4;

Al = lambda*A{1} + (1-lambda)*A{2};
bl = lambda*b{1} + (1-lambda)*b{2};
xe = -Al\bl;
l{1} = A{1} * xe + b{1};
l{2} = A{2} * xe + b{2};
global P Q
[P,Q] = calc_lmi(A,lambda);



%% Switched Affine System Model object

sys = swss(A,l,0,1,0,@(sys,state)sw_rule_old(Q,P,sys,state));
simout_old = swsim_old(sys,0:1e-5:20,[10 0],'silent')


sys = SwitchedAffineSystem(A,l,0,1,0,@(sys,state)sw_rule(Q,P,sys,state));
simout = swsim(sys,0:1e-5:20,[10 0],'silent')



%% Plot
% plot simulation
figure
for i = 1:size(init_pts,1)
    for k = 1:size(init_pts,2)
        x = sims{i}.x;
        plot(x(1:10:end,1),x(1:10:end,2));
        hold on;
    end
end






function [P,R] = calc_lmi(A,lamb)
    lambda = [lamb 1-lamb];
    
    n = size(A{1},1);

    setlmis([])
    P = lmivar(1, [n 1]);
    R{1} = lmivar(1, [n 1]);
    R{2} = lmivar(1, [n 1]);
    
    lmiterm([-newlmi,1,1,P],1,1);
    lmi = newlmi;
    lmiterm([lmi 1 1 P], A{1}',1,'s');
    lmiterm([lmi 1 1 R{1}],1,1);
    lmi = newlmi;
    lmiterm([lmi 1 1 P], A{2}',1,'s');
    lmiterm([lmi 1 1 R{2}],1,1);
    
    lmi = newlmi;
    for i = 1:2
        lmiterm([-lmi 1 1 R{i}],lambda(i),1);
    end
    
    lmisys = getlmis;
    c = zeros(1,decnbr(lmisys));
    for i = 1:decnbr(lmisys)
        c(i) = trace(defcx(lmisys,i,P));
    end
    options = [1e-4,200,0,200,1];
    [~,xopt] = mincx(lmisys,c,options);
    if ~isempty(xopt)
        P = dec2mat(lmisys,xopt,P);
        for i = 1:2
            R{i} = dec2mat(lmisys,xopt,R{i});
        end
    else
        error('infeasible');
    end
end


