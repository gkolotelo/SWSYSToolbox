function out = search_convex_combination( A, b, pts )

%
%   search_convex_combination v0.1 27-May-2018
%   Author: Guilherme Kairalla Kolotelo
%   Copyright 2018
%

% Parse inputs

if length(A) < 2 || length(A) > 3
     error('SwitchedSysToolBox:search_convex_combination','Only convex combinations for 2 or 3 subsystems is currently supported.');
end
if size(A{1},1) < 2 || size(A{1},1) > 3
     error('SwitchedSysToolBox:search_convex_combination','Only systems of second or third order are currently supported.');
end

if nargin < 3
    if length(A) == 3
        lambda_range = linspace(0,1,100);
    else
        lambda_range = linspace(0,1,1000);
    end
else
    lambda_range = linspace(0,1,pts);
end
if nargin < 2
    affine = false;
else
    affine = true;
end

out = {};



% ---------------------- 2 subsystems ----------------------
if length(A) == 2
        
    for l = lambda_range
        Aeq = A{1}*l + A{2}*(1-l);
        
        if max(real(eig(Aeq))) < 0
            out{end+1}{1} = l;
            if affine
                beq = b{1}*l + b{2}*(1-l);
                out{end}{2} = -Aeq\beq;
            end
        end
    end

    if affine
        fig = figure;
        for i = 1:length(out)
            scatter(out{i}{2}(1),out{i}{2}(2),'.');
            xlabel('x_1');
            ylabel('x_2');
            hold on
        end

        dcm_obj = datacursormode(fig); 
        set(dcm_obj,'UpdateFcn',@(empt,event_obj)myupdatefcn(out,empt,event_obj))
    end
    
end

% ----------------------------------------------------------




% ---------------------- 3 subsystems ----------------------
if length(A) == 3
    
    Z = NaN*zeros(length(lambda_range),length(lambda_range));
    step = lambda_range(2)-lambda_range(1);

    for l1 = 1:length(lambda_range)  
        lambda_range_2 = 0:step:(1-lambda_range(l1));
        for l2 = 1:length(lambda_range_2)
            l3 = 1-lambda_range(l1)-lambda_range_2(l2);
            if l3 > 1
                continue
            end
            Aeq = A{1}*lambda_range(l1) + A{2}*lambda_range_2(l2) + A{3}*l3;

            if max(real(eig(Aeq))) < 0
                Z(l1,l2) = max(real(eig(Aeq)));
                out{end+1}{1} = [l1;l2;l3];
                if affine
                    beq = b{1}*lambda_range(l1) + b{2}*lambda_range_2(l2) + b{3}*l3;
                    out{end}{2} = -Aeq\beq;
                end
            end
        end
    end


    if affine
        fig = figure;
        h = surf(lambda_range,lambda_range,Z);
        set(h,'linestyle','none');
        xlabel('l_1');
        ylabel('l_2');
        zlabel('max(real(eig(Aeq)))');
        dcm_obj = datacursormode(fig); 
        set(dcm_obj,'UpdateFcn',@(empt,event_obj)myupdatefcn(out,empt,event_obj))
    end
    
end
% ----------------------------------------------------------




function txt = myupdatefcn(out,empt,event_obj)
    pos = get(event_obj,'Position');
    lambda_txt = 'none';
    for k = 1:length(out)
        if out{k}{2}(1) == pos(1)
            lambda_txt = num2str(out{k}{1});
            aeq_txt = num2str(eig(A{1}*out{k}{1} + A{2}*(1-out{k}{1}))');
            break;
        end
    end
    txt = {['x1: ',num2str(pos(1))],...
          ['x2: ',num2str(pos(2))],...
          ['Lambda: ',lambda_txt],...
          ['eig(Aeq): ',aeq_txt]};
end








end