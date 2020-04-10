function str = get_inFilename( handles )
% The name of the image file currently being analyzed by the program is
% located in the UserData of the rerunSegmentation handle.
str = get( handles.rerunSegmentation, 'UserData' );