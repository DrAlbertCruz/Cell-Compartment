function set_outFilenamePath( str, handles )
% savePath is a property of eventLog
UserData = get( handles.eventLog, 'UserData' );
UserData.outFilenamePath = str;
set( handles.eventLog, 'UserData', UserData );