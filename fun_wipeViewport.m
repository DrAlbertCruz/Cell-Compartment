%% fun_wipeViewport()
% This function places a white image in the view screen
function fun_wipeViewport( handles )
wipe = [1];
imshow( wipe, [], 'Parent', handles.axes1 );