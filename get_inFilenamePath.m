function str = get_inFilenamePath( handles )
% savePath is a property of menuNew
UserData = get( handles.eventLog, 'UserData' );
str = UserData.inFilenamePath;