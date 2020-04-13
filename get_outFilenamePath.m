function str = get_outFilenamePath( handles )
% savePath is a property of menuNew
UserData = get( handles.menuNew, 'UserData' );
str = UserData.savePath;