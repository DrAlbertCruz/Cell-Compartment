%% fun_displayImage()
% Function for displaying an image in axes1
function fun_displayImage( image, handles )
imshow( image, [], 'Parent', handles.axes1 );