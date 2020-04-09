%% Notes
% Theres alot of functions here that are probably associated with a
% callback to a button that no longer exists but I'm afraid to start
% deleting things wily nily because it works at the moment.

function varargout = runGUI(varargin)
% RUNGUI MATLAB code for runGUI.fig
%      RUNGUI, by itself, creates a new RUNGUI or raises the existing
%      singleton*.
%
%      H = RUNGUI returns the handle to a new RUNGUI or the handle to
%      the existing singleton*.
%
%      RUNGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RUNGUI.M with the given input arguments.
%
%      RUNGUI('Property','Value',...) creates a new RUNGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before runGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to runGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help runGUI

% Begin initialization code - DO NOT EDIT
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
global options

handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes runGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%% DEFAULT VALUE SETTINGS
% STREL CLOSE SIZE
% This parameter is used to close holds that may have occured during
% segmentation.
%   20x - 2 (default)
%   40x - 3
%   60x - 4
options.strel_close_size = 2;
% CONTRAST METHOD
%   Contrast method:
%   0 - none
%   1 - Auto Contrast
%   2 - adaptive histogram equalization (default)
options.contrast_method = 2;
% HIT NEW
%   The first time the user hits 'new experiment' it should not pester them
%   with a prompt. This flag makes sure of that.
options.hitNew = false;
% UM/PIX Formula
%   Conversion to um from pixels
options.conv = .3225;
% Also obligatory initial settings
set( handles.menuSave, 'UserData', [] );
set( handles.menuNew, 'UserData', 1 );
%% STRINGS
% That are used in many places, and located here so they can be easily
% updated.
options.NEW_EXP_MSG = 'Data cleared. New experiment started.';
% Testing log
fun_updateLog( "Started program. To start a new experiment, click on File and New.", handles );

% --- Outputs from this function are returned to the command line.
function varargout = runGUI_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

%{
    Product help
%}
function menuHelp_Callback(hObject, eventdata, handles)
msgbox( [ 'Copying and distribution of this file, with or without modification, are permitted in any medium without royalty provided the copyright notice and this notice are preserved.  This file is offered as-is, without any warranty.' ], ...
    'About Program' );


function menuUpperFile_Callback(hObject, eventdata, handles)
% 4/3/2020 This function does nothing it only exists so that MATLAB does not throw a warning/error

%{
    Callback to create a new function. USERDATA: The number of loaded
    images.
%}
function menuNew_Callback(hObject, eventdata, handles)
global options

if options.hitNew % dont ask for this the first time they hit it
    ButtonName = questdlg('Starting a new experiment will clear all previous data/images. Clear all data?', ...
        'Clear all data?', ...
        'Yes', 'No', 'No' );
    
    switch ButtonName
        case 'Yes'
            set( handles.menuSave, 'UserData', [] );
            set( hObject, 'UserData', 1 );
            fun_updateLog( options.NEW_EXP_MSG, handles );
        case 'No'
            fun_updateLog( "File->New command aborted.", handles );
    end
else
    set( handles.menuSave, 'UserData', [] );
    set( hObject, 'UserData', 1 );
    fun_updateLog( options.NEW_EXP_MSG, handles );
end
% Toggle 'hit new'so that they get a prompt whenever they start a new
% experiment.
options.hitNew = true;

%{
    Callback for when the attempt to load a new image. Note that this is
    where we store the current image.
%}
function menuOpen_Callback(hObject, eventdata, handles)
% User data will have the previous path
global options
% This callback's 'UserData' contains the previous path.
prevPath = get( hObject, 'UserData' );

[file,path] = uigetfile( [ prevPath '*.*' ], 'Load An Image' );

% 'path == 0' must indicate some sort of error when loading the image,
% probably need to validate this
if path ~= 0
    try
        image = fun_loadImage( path, file, handles );
    catch e
        error( 'Error when loading the image in menuOpen callback.' );
    end
    
    % Display the image in the preview pane
    try
        imshow( image, [], 'Parent', handles.axes1 );
        % handles.menuOpen handle contains the image file
        set( handles.menuOpen, 'UserData', image );
        set( hObject, 'UserData', path );   % save previous path
        % Give instructions. Commented out on 4/9 because it was redundant
%         fun_updateLog( "Click which cells to process. Press enter when done.", handles );
    catch e
        error( 'Error when attempting to display preview of image.' );
    end
        
    data = fun_analyzeCells( image, handles ); 
    % Once the first image has been loaded, then let them click on the
    % button to re-segment
    set( handles.rerunSegmentation, 'Enable', 'on' );
        
        
        % This code most likely needs to be in another part
        
        if ~isempty( data )
            n = data(size(data,1),1);
            dataOld = get( handles.menuSave, 'UserData' );
            data = [ [ ones(size(data,1),1) * get(handles.menuNew,'UserData') data]; ...
                dataOld ];
            
            set( handles.menuSave, 'UserData', data );
            set( handles.menuNew, 'UserData', get(handles.menuNew,'UserData') + 1 );
%             set( handles.text1, 'String', [ 'Complete with image ' num2str(get(handles.menuNew,'UserData')-1) ...
%                 ' (' num2str(n) ' cells). Waiting ...' ] );
            fun_updateLog( [ 'Complete with image ' num2str(get(handles.menuNew,'UserData')-1) ...
                ' (' num2str(n) ' cells). Waiting ...' ], handles );
        end
   % catch e
   %     error( 'Error (in runGUI) : Bad, bad very bad error when processing a cell. Call Albert.' );
   % end
end

%{
    Callback to export data to XLS file. USERDATA: The matrix of data
%}
function menuSave_Callback(hObject, eventdata, handles)
path = get( handles.menuSaveCSV, 'UserData' );
data = get( hObject, 'UserData' );

[file,path] = uiputfile( fullfile( path, 'myExp.xls' ),'Save Experiment As');
if path ~= 0 & ~ isempty( data )
    xlswrite( fullfile( path, file ), data );
else
%     set( handles.text1, 'String', 'Save aborted (Possibly empty data, or bad path).' );
    fun_updateLog( "Save aborted (Possibly empty data, or bad path).", handles );
end

%{
    Saves as a csv, contains path for saves
%}
function menuSaveCSV_Callback(hObject, eventdata, handles)
path = get( hObject, 'UserData' );
data = get( handles.menuSave, 'UserData' );

[file,path] = uiputfile( fullfile( path, 'myExp.csv' ),'Save Experiment As');
if path ~= 0 & ~ isempty( data )
    csvwrite( fullfile( path, file ), data );
else
%     set( handles.text1, 'String', 'Save aborted (Possibly empty data, or bad path).' );
    fun_updateLog( "Save aborted (Possibly empty data, or bad path).", handles );
end


%{
    Close function
%}
function menuQuit_Callback(hObject, eventdata, handles)
close all


%{
    The GO button
%}
% function pushbutton1_Callback(hObject, eventdata, handles)
% image = get( handles.menuOpen, 'UserData' );


% --------------------------------------------------------------------
function menuUpperEdit_Callback(hObject, eventdata, handles)
% hObject    handle to menuUpperEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%{
    Callback for menu options. Note that this is where we set our option
    preferences.
%}
function menuOptions_Callback(hObject, eventdata, handles)
options = get( hObject, 'UserData' );

prompt={'Enter the size for morphological close (Default 7. Decrease this to 3 for really small cells. Must be odd. Minimum is 3, dont go above 13 or so):'};
name='Options for Analysis';
numlines=1;
defaultanswer={num2str(options.strel_close_size)};

answer=inputdlg(prompt,name,numlines,defaultanswer);

options.strel_close_size = str2double( cell2mat( answer(1) ) );

set( hObject, 'UserData', options );

%% Parameter Callbacks
%{
    Contrast adjustment pulldown menu.
%}

function popupcontrast_Callback(hObject, eventdata, handles)
global options
options.contrast_method = get( hObject, 'Value' ) - 1;

function popupcontrast_CreateFcn(hObject, eventdata, handles)
global options
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set( hObject, 'Value', options.contrast_method + 1 );

%{
    Contrast adjustment pulldown menu.
%}

function popupmagnification_Callback(hObject, eventdata, handles)
global options
switch get( hObject, 'Value' )
    case 1 % x20
        options.strel_close_size = 2;
    case 2 % x40
        options.strel_close_size = 3;
    case 3 % x60
        options.strel_close_size = 4;
    otherwise
        options.strel_close_size = 2;
end

% --- Executes during object creation, after setting all properties.
function popupmagnification_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set( hObject, 'Value', 1 ); % default, corresponds to x20


%{
    um/pixel conversion. USERDATA for edit1: um/pixel conversion (double)
%}
function edit1_Callback(hObject, eventdata, handles)
global options
options.conv = str2double( get( hObject, 'String' ) );

function edit1_CreateFcn(hObject, eventdata, handles)
global options
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set( hObject, 'String', num2str( options.conv ) );



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
