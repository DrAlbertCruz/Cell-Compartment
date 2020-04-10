function set_inFilename( str, handles )
%% TODO: Validation ... is this an image file?

% The name of the image file currently being analyzed by the program is
% located in the UserData of the rerunSegmentation handle.
set( handles.rerunSegmentation, 'UserData', str  );