%% fun_analyzeCells
% As of v101, this function should only be called to segment the image and
% display a psuedo-color on the main viewport
function data = fun_analyzeCells( ...
    arru8Image, ... This is the image to be analyzed. Array of uint8
    handles ) 

% Lock the segmentation button so the user doesn't keep spamming it
set( handles.rerunSegmentation, 'Enable', 'off' );
% Note in the log that we started.
fun_updateLog( "Segmentation algorithm has started.", handles );
tic

%% PARAMETER INITIALIZATION: Based on handles
CONTRAST_METHOD = get( handles.popupcontrast, 'Value' ) - 1;
EDGE_METHOD = get( handles.popupedge, 'Value' ) - 1;
CLOSE_SIZE = get( handles.strelSize, 'UserData' );
STREL_METHOD = get( handles.popupmenu5, 'Value' );

UserData = get( handles.axes1, 'UserData' );

%% PARAMETER INITIALIZATION: Based on this function
UserData.originalImage = arru8Image;
PARAM_IMAGE_SIZE    = 750;
data                = [];

% Initialize filters. Reflecting on past work here it seems that I
% generated 2 separated DOG filters.


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


%% Part 5: IMAGE CLOSE
% Image closing operation to touch up the segmentation from the edge
% detector
switch STREL_METHOD
    case 1 % Diamond
        strel_operator = strel('diamond',CLOSE_SIZE);
    case 2 % Square
        strel_operator = strel('square',CLOSE_SIZE);
    case 3 % Sphere
        strel_operator = strel('sphere',CLOSE_SIZE);
end
BWClosed = imclose( BW, ...
    strel_operator );

imshow( BWClosed, [] );

%% Part 6: IDENTIFY OBJECTS
% Identify possible cells by inverting the masked image from the previous
% step, and then conjuncting it with the ROI mask calculated at the
% beginnning of segmentation
BWClosed = ~( BWClosed );
% Now CC
BWCC = bwlabel( BWClosed );
BWCC( ~ROI ) = 0;


%% PART 7: PSEUDOCOLOR IMAGE
% To help the user click on the stuff that they want to click on. This is a
% kind of hacky thing with the RGB channels.
colorizedPreview = .5 * repmat( imAdjusted, [ 1 1 3 ] ) + ...
    .5 * double( label2rgb( BWCC, 'jet', [0 0 0], 'shuffle' ) ) ./ 255;
imshow( colorizedPreview, [], 'Parent', handles.axes1 );
% Save onto UserData for some persistence
UserData.colorizedPreview = colorizedPreview;

% Set the data for the image in axes1 user data for some persistence
set( handles.axes1, 'UserData', UserData );
% Enable the segmentation button now that were complete
set( handles.rerunSegmentation, 'Enable', 'on' );
% Note in the log that we started.
toc;
fun_updateLog( strcat( "Segmentation algorithm completed in ", num2str( toc ), " seconds." ),...
    handles );

% ButtonName = questdlg('Was the segmentation OK?', ...
%     'Was the segmentation OK?', ...
%     'Yes', 'No', 'No' );
% 
% if strcmp( ButtonName, 'Yes' )
%     compartment = zeros(size(BWClosed));
%     count = 1;
%     try
%         while true
% %             title( 'Click on the cell you want to analyze. Close when done.' );
% %             set( handles.axes1, 'String', ...
% %                 'Click on the cell you want to analyze. Hit enter when done.' );
%             fun_updateLog( "Click on the cell you want to analyze. Hit enter when done.", handles );
%             [xi(count), yi(count)] = ginput( 1 );
%             hold on; scatter( xi(count), yi(count) );
%             count = count + 1;
%         end
%     catch e
%         xi = fix( xi );
%         yi = fix( yi );
%         ccount = 1;
%         for jj = 1:length(xi)
%             compartment( BWCC == BWCC( yi(jj), xi(jj) ) ) = ccount;
%             ccount = ccount + 1;
%         end
%     end
%     
%     stats = regionprops( compartment, 'all' );
%     
%     data = zeros( size( stats, 1 ), 7 );
%     k = aspectratio * fAspect;
%     k2 = k ^ 2;
%     
%     for ii=1:size( stats, 1 )
%         data( ii, 1 ) = ii;
%         data( ii, 2 ) = stats(ii).MajorAxisLength * k;
%         data( ii, 3 ) = stats(ii).MinorAxisLength * k;
%         data( ii, 4 ) = stats(ii).Area * k2;
%         data( ii, 5 ) = stats(ii).Perimeter * k;
%         data( ii, 6 ) = stats(ii).Orientation;
%         data( ii, 7 ) = timeTaken;
%     end
% else
%     f = errordlg( 'Image load aborted, please tweak parameters.', 'Deepest apologies...' );
%     data = [];
% end
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