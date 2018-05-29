function index = sw_rule(Q,P,swsys,state)
    v = zeros(swsys.N,1);
    for i=1:swsys.N
        v(i) = - state.x' * Q{i} * state.x + 2 * state.x' * P * swsys.b{i};
    end
    [~ ,index] = min(v);
end