%% fun_saveCells()
% Function to save the user data to a file based on file type, located in
% handles.popupmenuFileType.
function fun_saveCells( handles )
% Initially, disable the button to select cells once they move on to this
% phase.
set( handles.selectCells, 'Enable', 'off' );

%% Part 1: Get user data
data = get_data( handles );

%% Part 2: Determine what file type we must save to
fileType = get( handles.popupmenuFileType, 'Value' );
% 1 - CSV
switch fileType
    case 1
        FILE_TYPE = '.csv';
end
% Get the path, if its 0 that means we have no attempted a save yet
path = get_outFilenamePath( handles );
if path == 0
    path = cd;
end

%% Part 3: Ask user for the save file location
[file,path] = uiputfile( fullfile( path, strcat( 'myExp', FILE_TYPE ) ),'Save experiment as ...');

% Validation, stop if there was an error specifying where we should save
if path == 0 
    return;
end

% Save old directory information
set_outFilename( file, handles );
set_outFilenamePath( path, handles );

%% Part 4: Save the file
% Switch based on the type of file to save to
switch fileType
    case 1
        fun_saveCSV( data, handles );
end

% Notify user of save
fun_updateLog( strcat( "Saved cell results to ", fullfile( path, file ), "." ), ...
    handles );