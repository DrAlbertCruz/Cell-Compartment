%% fun_loadImage( path, file, handles )
% Function used by runGUI.m to load an image
function image = fun_loadImage( path, file, handles )
FILE_NAME = fullfile( path, file );
image = imread( FILE_NAME );
fun_updateLog( strcat( "Loaded image ", file, " successfully." ), handles );