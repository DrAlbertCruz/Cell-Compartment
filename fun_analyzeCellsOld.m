%% fun_analyzeCells
% As of v101, this function should only be called to segment the image and
% display a psuedo-color on the main viewport
function data = fun_analyzeCells( ...
    arru8Image, ... This is the image to be analyzed. Array of uint8
    iCloseSize, ... This is the structure element for the morphological close operation to touch up the segmentation results.
    iContrastMethod, ... This controls which segmentation algorithm is used
    fAspect, ... This is the conversion to um for real measurements
    handles ) % This is the status
% 3/26/20: Why did this need to be persistent
% persistent filter_dX filter_dY strel_close PARAM_FILTER PARAM_IMAGE_SIZE

%% PARAMETER INITIALIZATION: Based on handles
CONTRAST_METHOD = get(handles.popupcontrast, 'Value') - 1;
EDGE_METHOD = get(handles.popupedge, 'Value') - 1;

% Parameters set in this function
PARAM_IMAGE_SIZE    = 750;
data                = [];

% Initialize filters. Reflecting on past work here it seems that I
% generated 2 separated DOG filters.
strel_close = strel('diamond',iCloseSize);

% Why is this 'tic' here?
tic

arru8Image = preprocessImage( arru8Image );

%{
    Part 1: Resize to 750, maintaining aspect ratio
%}
if size( arru8Image, 2 ) > size( arru8Image, 1 )
    aspectratio = size( arru8Image, 2 ) / 750;
    arru8Image = imresize( arru8Image, [NaN PARAM_IMAGE_SIZE] );
else
    aspectratio = size( arru8Image, 1 ) / 750;
    arru8Image = imresize( arru8Image, [PARAM_IMAGE_SIZE NaN] );
end

%{
    Part 2: Get ROI first before we do anything
%}
% Use MATLAB's Gaussian Mixture model fit to generate a mask of the image
obj = gmdistribution.fit(arru8Image(:),2);
% Use a clustering algorithm to CC label the components
[idx,~] = cluster(obj,arru8Image(:));
[~, order] = sort( obj.mu );
ROI = reshape( idx == order(2), size( arru8Image ) );
arru8Image( ~ROI ) = 0;

%{
    Part 3: Contrast adjustment of the image
%}
switch CONTRAST_METHOD
    case 0
        imAdjusted = arru8Image;
    case 1
        imAdjusted = imadjust( arru8Image );
    case 2
        imAdjusted = adapthisteq( arru8Image );
    otherwise
        error( 'ERROR (In fun_analyzeCells) : Unknown auto contrast method!' );
end


%{ 
    Part 4: Edge detector
%}
switch EDGE_METHOD
    case 0 % DOG
        PARAM_FILTER        = [1 8 0 -8 -1];                            % 1-D DOG
        filter_dX = repmat( PARAM_FILTER, length(PARAM_FILTER), 1 );    % filt X
        filter_dY = repmat( PARAM_FILTER', 1, length(PARAM_FILTER) );   % filt Y
    case 1 % Sobel
        filter_dX = [ 1, 0, -1; 2, 0, -2; 1, 0, -1];
        filter_dY = [ 1, 2, 1; 0, 0, 0; -1, -2, -1];
    case 2 % Prewitt
        filter_dX = [ 1, 0, -1; 1, 0, -1; 1, 0, -1];
        filter_dY = [ 1, 1, 1; 0, 0, 0; -1, -1, -1];
    case 3 % Roberts cross
        filter_dX = [ 1, 0; 0, -1 ];
        filter_dY = [ 0, 1; -1, 0 ];
    otherwise
        error( 'ERROR (In fun_analyzeCells) : Unknown auto contrast method!' );
end
edgesX = imfilter( imAdjusted, filter_dX, 'same' );
edgesY = imfilter( imAdjusted, filter_dY, 'same' );
edgesMag = sqrt( edgesX.^2 + edgesY.^2 );
edgesMag = mat2gray( edgesMag );
% Following line removed 4/9
% edgesMag = imadjust( edgesMag );
BW = im2bw( edgesMag, graythresh( edgesMag ) );


% Close it
BWClosed = imclose( BW, ...
    strel_close );


%{
    Part 2.b, we want to get a mask for the object they clicked on.
%}
% Invert the image
BWClosed = ~( BWClosed );

% Now CC
BWCC = bwlabel( BWClosed );
BWCC( ~ROI ) = 0;


%{
    This is the part where we ask them to click on the cell.
%}
% h = figure;
preview = .6 * repmat( imAdjusted, [ 1 1 3 ] ) + ...
    .4 * double( label2rgb( BWCC, 'jet', [0 0 0], 'shuffle' ) ) ./ 255;
% if ~verbose
    imshow( preview, [], 'Parent', handles.axes1 );
% else
%     imshow( preview, [] );
% end

ButtonName = questdlg('Was the segmentation OK?', ...
    'Was the segmentation OK?', ...
    'Yes', 'No', 'No' );

if strcmp( ButtonName, 'Yes' )
    compartment = zeros(size(BWClosed));
    count = 1;
    try
        while true
%             title( 'Click on the cell you want to analyze. Close when done.' );
%             set( handles.axes1, 'String', ...
%                 'Click on the cell you want to analyze. Hit enter when done.' );
            fun_updateLog( "Click on the cell you want to analyze. Hit enter when done.", handles );
            [xi(count), yi(count)] = ginput( 1 );
            hold on; scatter( xi(count), yi(count) );
            count = count + 1;
        end
    catch e
        xi = fix( xi );
        yi = fix( yi );
        ccount = 1;
        for jj = 1:length(xi)
            compartment( BWCC == BWCC( yi(jj), xi(jj) ) ) = ccount;
            ccount = ccount + 1;
        end
    end
    
    stats = regionprops( compartment, 'all' );
    
    data = zeros( size( stats, 1 ), 7 );
    k = aspectratio * fAspect;
    k2 = k ^ 2;
    
    for ii=1:size( stats, 1 )
        data( ii, 1 ) = ii;
        data( ii, 2 ) = stats(ii).MajorAxisLength * k;
        data( ii, 3 ) = stats(ii).MinorAxisLength * k;
        data( ii, 4 ) = stats(ii).Area * k2;
        data( ii, 5 ) = stats(ii).Perimeter * k;
        data( ii, 6 ) = stats(ii).Orientation;
        data( ii, 7 ) = timeTaken;
    end
else
    f = errordlg( 'Image load aborted, please tweak parameters.', 'Deepest apologies...' );
    data = [];
end
end

%% segmentationState()
% The first phase of analysis where you try to get a good segmentation mask
function segmentationState(handles)
%% Part 1: Get state variables from handles


end

%% preprocessImage( arru8Image )
% Function responsible for preprocessing the image, converting it to
% grayscale and other things
function result = preprocessImage( arru8Image )
%% Part 1: Check if image is RGB
% If the image is RGB then convert it to grayscale
if size( arru8Image, 3 ) > 1 % Check for for color.
    % Use MATLAB's rgb2gray function to convert it to a grayscale image
    arru8Image = double( rgb2gray( arru8Image ) ); 
end
%% Part 2: Normalize
% Normalize the image so that it's intensity values range from 0:1. Use
% MATLAB's built in mat2gray function for this.
arru8Image = mat2gray( arru8Image ); 
%% Part 3: A very slight blur
filter = [1 2 1; 2 4 2; 1 2 1] ./ 16;
result = conv2( arru8Image, filter, 'same');
end

% function verboseNewFigure( initialize )
% persistent currentCount;
% if nargin == 1
%     currentCount = initialize;
% else
%     currentCount = currentCount + 1;
% end
% count = currentCount;
% figure( count );
% end