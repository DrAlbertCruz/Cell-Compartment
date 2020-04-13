%% fun_newImage( handles )
% Behavior when a user clicks to start a new experiment
function fun_newImage( handles )

ButtonName = questdlg('Starting a new experiment will clear all previous data/images. Clear all data?', ...
    'Clear all data?', ...
    'Yes', 'No', 'No' );

switch ButtonName
    case 'Yes'
        % Change the file name to nothing, but save all previous paths
        set_inFilename( [], handles );
        set_outFilename( [], handles );
        % Message to eventLog
        fun_updateLog( 'Data cleared. New experiment started.', handles );
        
        % Wipe the viewport
        fun_wipeViewport( handles )
        
        % Disable all three button
        set( handles.rerunSegmentation, 'Enable', 'off' );
        set( handles.selectCells, 'Enable', 'off' );
        set( handles.pushbuttonSave, 'Enable', 'off' );
        
        data.k = 0;
        % Clear the previous data
        set_data( handles, data.k );
    case 'No'
        fun_updateLog( "File->New command aborted.", handles );
end