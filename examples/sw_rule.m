function index = sw_rule(Q,P,swsys,state)
    v = zeros(swsys.Ndim(),1);
    for i=1:swsys.Ndim()
        v(i) = - state.x' * Q{i} * state.x + 2 * state.x' * P * swsys.subsystems{i}.b;
    end
    [~ ,index] = min(v);
end
