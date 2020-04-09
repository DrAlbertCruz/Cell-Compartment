% fun_evalStrelSize()
%   Used to evalute the *real* size of the structuing element for the
%   morphological operation because the MATLAB slider has a real value from
%   0 to 60.
function result = fun_evalStrelSize( value )
result = 3 + 2 * round(value);