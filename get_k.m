%% get_k()
% The conversion factor from um to pixels
function k = get_k( handles )
k = str2double( get( handles.edit1, "String" ) );