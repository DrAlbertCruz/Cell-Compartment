function set_inFilename( str, handles )
% The name of the image file currently being analyzed by the program is
% located in the UserData of the eventLog handle.
UserData = get( handles.eventLog, 'UserData'  );
UserData.inFilename = str;
set( handles.eventLog, 'UserData', UserData );