function set_outFilenamePath( str, handles )
% savePath is a property of menuNew
UserData = get( handles.menuNew, 'UserData' );
UserData.savePath = str;
set( handles.menuNew, 'UserData', UserData );