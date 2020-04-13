% Begin initialization code - DO NOT EDIT
function varargout = runGUI(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @runGUI_OpeningFcn, ...
    'gui_OutputFcn',  @runGUI_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before runGUI is made visible.
function runGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% No idea what this thing does
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes runGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Initialize state variables located in UserData of GUI components
set_inFilenamePath( [], handles );
set_inFilename( [], handles );
set_outFilename( [], handles );
set_outFilenamePath( [], handles );
% Testing log
fun_updateLog( "Started program. To start a new experiment, click on File and New.", handles );
% Wipe the viewport so that the screen is empty
fun_wipeViewport( handles )

% --- Outputs from this function are returned to the command line.
function varargout = runGUI_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

% --- Product help
function menuHelp_Callback(hObject, eventdata, handles)
msgbox( [ 'Copying and distribution of this file, with or without modification, are permitted in any medium without royalty provided the copyright notice and this notice are preserved.  This file is offered as-is, without any warranty.' ], ...
    'About Program' );


function menuUpperFile_Callback(hObject, eventdata, handles)
% 4/3/2020 This function does nothing it only exists so that MATLAB does not throw a warning/error

% --- User hits 'File->New'
function menuNew_Callback(hObject, eventdata, handles)
fun_newImage( handles );

% --- User hits 'File->Open'
function menuOpen_Callback(hObject, eventdata, handles)
% Prompt
[file,path] = uigetfile( fun_filterSpec, 'Load An Image' );

% 'path == 0' must indicate some sort of error when loading the image,
% probably need to validate this
if path ~= 0
    % Set official file name within the program
    set_inFilename( file, handles );
    set_inFilenamePath( path, handles );
    
    try
        image = fun_loadImage( path, file, handles );
    catch e
        error( 'Error when loading the image in menuOpen_Callback().' );
    end
    
    
    try
        % Display the image in the preview pane
        fun_displayImage( image, handles )
    catch e
        error( 'Error when attempting to display preview of image.' );
    end
    
    data = fun_analyzeCells( image, handles );
    % Once the first image has been loaded, then let them click on the
    % button to re-segment
    set( handles.rerunSegmentation, 'Enable', 'on' );
end

% --- 'File->Quit'
function menuQuit_Callback(hObject, eventdata, handles)
close all

% --------------------------------------------------------------------
function menuUpperEdit_Callback(hObject, eventdata, handles)
% Does nothing, MATLAB throws a fit if this does not exist

%% Parameter Callbacks
function popupcontrast_Callback(hObject, eventdata, handles)
% global options
% options.contrast_method = get( hObject, 'Value' ) - 1;

function popupcontrast_CreateFcn(hObject, eventdata, handles)
% global options
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% set( hObject, 'Value', options.contrast_method + 1 );

%{
    um/pixel conversion. USERDATA for edit1: um/pixel conversion (double)
%}
function edit1_Callback(hObject, eventdata, handles)
% global options
% options.conv = str2double( get( hObject, 'String' ) );

function edit1_CreateFcn(hObject, eventdata, handles)
% global options
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% set( hObject, 'String', num2str( options.conv ) );



% --- Executes on selection change in eventLog.
function eventLog_Callback(hObject, eventdata, handles)
% hObject    handle to eventLog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns eventLog contents as cell array
%        contents{get(hObject,'Value')} returns selected item from eventLog


% --- Executes during object creation, after setting all properties.
function eventLog_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eventLog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupedge.
function popupedge_Callback(hObject, eventdata, handles)
global options
options.edge_method = get( hObject, 'Value' ) - 1;

% --- Executes during object creation, after setting all properties.
function popupedge_CreateFcn(hObject, eventdata, handles)
global options
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set( hObject, 'Value', 1 ); % Set default value to first


% --- Executes on slider movement. Must update the user text to let them
% know what value this corresponds to.
function strelSize_Callback(hObject, eventdata, handles)
% Use a separate function to determine what the actual value of this should
% be.
value = fun_evalStrelSize( hObject.Value );
% Make sure that when the user clicks on this slider UserData is set with
% the value that should be used.
hObject.UserData = value;
% Finally, update the string telling the user the overall size
set( handles.textStrelSize, ...
    'String', ...
    strcat( "Morph. operator strength: ", num2str(value) ) );

% --- Executes during object creation, after setting all properties.
function strelSize_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
hObject.Value = 2;
% Use a separate function to determine what the actual value of this should
% be.
value = fun_evalStrelSize( hObject.Value );
% Make sure that when the user clicks on this slider UserData is set with
% the value that should be used.
hObject.UserData = value;


% --- Executes on selection change in popupmenu5. popupmenu5 is the type of
% morphological operation to use in segmentation.
function popupmenu5_Callback(hObject, eventdata, handles)
% Do nothing

% --- Executes during object creation, after setting all properties.
% popupmenu5 is the type of morphological operation to use in segmentation.
function popupmenu5_CreateFcn(hObject, eventdata, handles)
% Do nothing
hObject.Value = 2; % Default value


% --- Executes on button press in rerunSegmentation.
function rerunSegmentation_Callback(hObject, eventdata, handles)
% Button the user clicks to re-run segmentation algorithm
fun_updateLog( "Rerunning segmentation algorithm.", handles );
imageData = get( handles.axes1, 'UserData' );
fun_analyzeCells( imageData.originalImage, handles );


% --- Executes on button press in selectCells.
function selectCells_Callback(hObject, eventdata, handles)
% hObject    handle to selectCells (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fun_selectCells( handles );


% --- Executes on selection change in popupmenuFileType.
function popupmenuFileType_Callback(hObject, eventdata, handles)
% Do nothing

% --- Executes during object creation, after setting all properties.
function popupmenuFileType_CreateFcn(hObject, eventdata, handles)
% Do nothing
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonSave.
function pushbuttonSave_Callback(hObject, eventdata, handles)
fun_saveCells( handles );

% --- Executes during object creation, after setting all properties.
function pushbuttonSave_CreateFcn(hObject, eventdata, handles)
hObject.UserData = 0; % Initial value of 0 indicates that a path is not yet set.
