function set_inFilenamePath( str, handles )
% savePath is a property of eventLog
UserData = get( handles.eventLog, 'UserData' );
UserData.inFilenamePath = str;
set( handles.eventLog, 'UserData', UserData );