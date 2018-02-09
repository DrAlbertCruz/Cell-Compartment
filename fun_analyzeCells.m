%{
    Edit this, this is the algorithm
%}
function data = fun_analyzeCells( image, strel_close_size, contrast_method, conversion, paneHandle, statusHandle )
if nargin == 0
    % Test case for the data
    clc
    close all
    strel_close_size = 2;
    image = ...
        imread( fullfile( 'samples', '2-9-2018.tif' ) );
    verbose = true;
    %{
        Contrast method:
        0 - none
        1 - Auto Contrast
        2 - adaptive histogram equalization
    %}
    contrast_method = 2;
else
    verbose = false;
end

persistent filter_dX filter_dY strel_close PARAM_FILTER PARAM_IMAGE_SIZE

% Parameters
PARAM_FILTER        = [1 8 0 -8 -1]; % 1-D DOG
PARAM_IMAGE_SIZE    = 750;
data                = [];

% Initialize filters. Reflecting on past work here it seems that I
% generated 2 separated DOG filters.
filter_dX = repmat( PARAM_FILTER, length(PARAM_FILTER), 1 );    % filt X
filter_dY = repmat( PARAM_FILTER', 1, length(PARAM_FILTER) );   % filt Y
strel_close = strel('diamond',strel_close_size);

tic
if size( image, 3 ) > 1                     % Check for for color.
    image = double( rgb2gray( image ) );    % OK to override 'image'
end
image = mat2gray( image );                 % Also normalize the image.

if verbose
    verboseNewFigure( 1 );
    imshow( image, [] );
    title( 'Normalized image' );
end

%{
    Part 1: Resize to 750, maintaining aspect ratio
%}
if size( image, 2 ) > size( image, 1 )
    aspectratio = size( image, 2 ) / 750;
    image = imresize( image, [NaN PARAM_IMAGE_SIZE] );
else
    aspectratio = size( image, 1 ) / 750;
    image = imresize( image, [PARAM_IMAGE_SIZE NaN] );
end

if verbose
    verboseNewFigure;
    imshow( image, [] );
    title( 'Resized image' );
end

%{
    Part 2: Get ROI first before we do anything
%}
obj = gmdistribution.fit(image(:),2);
[idx,~] = cluster(obj,image(:));
[~, order] = sort( obj.mu );
ROI = reshape( idx == order(2), size( image ) );

if verbose
    verboseNewFigure;
    imshow( ROI, [] );
    title( 'Detected ROI' );
end

%{
    Part 3: Now pre-process image
%}
image = mat2gray( image );
image( ~ROI ) = 0;

%% Switch for image contrast adjustment
switch contrast_method
    case 0
        imAdjusted = image;
    case 1
        imAdjusted = imadjust( image );
    case 2
        imAdjusted = adapthisteq( image );
    otherwise
        error( 'ERROR (In fun_analyzeCells) : Unknown auto contrast method!' );
end

% Blur it a little bit and open it
% imageBlurred = imfilter( imAdjusted, ...
%     fspecial( 'gaussian' ), ...
%     'symmetric' );
% imageBlurred = imAdjusted;

if verbose
    verboseNewFigure;
    imshow( imAdjusted, [] );
    title( 'Post-processing' );
end

% Edge detector
edgesX = imfilter( imAdjusted, filter_dX, 'same' );
edgesY = imfilter( imAdjusted, filter_dY, 'same' );
edgesMag = sqrt( edgesX.^2 + edgesY.^2 );

if verbose
    verboseNewFigure;
    imshow( edgesMag, [] );
    title( 'Edge magnitudes' );
end

% Now threshold edgesMag
edgesMag = mat2gray( edgesMag );
edgesMag = imadjust( edgesMag );
BW = im2bw( edgesMag, graythresh( edgesMag ) );
% % BW = edgesMag > min( min( edgesMag ) );             % take all edges
% BW = edgesMag > ( mean( mean( edgesMag ) ) ...
%     - 0 * std( std( edgesMag ) ) );             % take all edges

if verbose
    verboseNewFigure;
    imshow( BW, [] );
    title( 'Thresh, edge magnitudes' );
end

% Close it
BWClosed = imclose( BW, ...
    strel_close );

if verbose
    verboseNewFigure;
    imshow( BWClosed, [] );
    title( 'Post BW cleanup' );
end

if verbose              % Figures terminate here
    verboseNewFigure;
end

%{
    Part 2.b, we want to get a mask for the object they clicked on.
%}
% Invert the image
BWClosed = ~( BWClosed );

% Now CC
BWCC = bwlabel( BWClosed );
BWCC( ~ROI ) = 0;

timeTaken = toc;

%{
    This is the part where we ask them to click on the cell.
%}
% h = figure;
preview = .6 * repmat( imAdjusted, [ 1 1 3 ] ) + ...
    .4 * double( label2rgb( BWCC, 'jet', [0 0 0], 'shuffle' ) ) ./ 255;
if ~verbose
    imshow( preview, [], 'Parent', paneHandle );
else
    imshow( preview, [] );
end

ButtonName = questdlg('Was the segmentation OK?', ...
    'Was the segmentation OK?', ...
    'Yes', 'No', 'No' );

if strcmp( ButtonName, 'Yes' )
    compartment = zeros(size(BWClosed));
    count = 1;
    try
        while true
%             title( 'Click on the cell you want to analyze. Close when done.' );
            set( statusHandle, 'String', ...
                'Click on the cell you want to analyze. Close when done.' );
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
    k = aspectratio * conversion;
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

function verboseNewFigure( initialize )
persistent currentCount;
if nargin == 1
    currentCount = initialize;
else
    currentCount = currentCount + 1;
end
count = currentCount;
figure( count );
end