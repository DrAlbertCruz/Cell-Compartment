function str = get_outFilename( handles )
% saveFilename is a property of menuNew
UserData = get( handles.eventLog, 'UserData' );
str = UserData.outFilename;