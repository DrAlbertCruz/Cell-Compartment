function str = get_outFilenamePath( handles )
% savePath is a property of menuNew
UserData = get( handles.eventLog, 'UserData' );
str = UserData.outFilenamePath;