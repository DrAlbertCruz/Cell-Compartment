function set_outFilename( str, handles )
% saveFilename is a property of eventLog
UserData = get( handles.eventLog, 'UserData' );
UserData.outFilename = str;
set( handles.eventLog, 'UserData', UserData );