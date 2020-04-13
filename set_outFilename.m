function set_outFilename( str, handles )
% saveFilename is a property of menuNew
UserData = get( handles.menuNew, 'UserData' );
UserData.saveFilename = str;
set( handles.menuNew, 'UserData', UserData );