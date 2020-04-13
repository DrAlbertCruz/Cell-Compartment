function str = get_inFilename( handles )
% The name of the image file currently being analyzed by the program is
% located in the UserData of the eventLog handle.
UserData = get( handles.eventLog, 'UserData'  );
try
    str = UserData.inFilename;
catch e
    str = [];
end