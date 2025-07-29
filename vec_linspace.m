function y = vec_linspace(start, goal, steps)
start = start';
goal = goal';
x = linspace(0,1,steps);
% difference = (goal - start);
%
% multip = difference'*x;
%
% onesvec = ones(1, steps);
% startvec = start' * onesvec;
%
% y = startvec + multip;
y = start' * ones(1, steps) + (goal - start)'*x;