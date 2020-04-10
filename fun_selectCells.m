%% fun_analyzeCells
% As of v101, this function should only be called to segment the image and
% display a psuedo-color on the main viewport
function data = fun_selectCells( handles )
% Lock the segmentation button permanently because this is considered
% moving into phase 2.
set( handles.rerunSegmentation, 'Enable', 'off' );
% Note in the log that we started.
fun_updateLog( "Beginning phase where user clicks on cells. Click on a cell to analyze.", handles );
% Get user data
UserData = get( handles.axes1, 'UserData' );

% What is compartment? Compartment is an image that contains the image of
% cells to be analyzed by the connected components algorithm.

compartment = zeros( size(UserData.BWClosed) );
% Cell count is 'count'
count = 1;

try
    while true
        %             title( 'Click on the cell you want to analyze. Close when done.' );
        %             set( handles.axes1, 'String', ...
        %                 'Click on the cell you want to analyze. Hit enter when done.' );
        fun_updateLog( "Click on a new cell you want to analyze. Hit enter when done.", handles );
        [xi(count), yi(count)] = ginput( 1 );
        hold on; scatter( xi(count), yi(count) );
        fun_updateLog( ...
                        strcat( "User clicked on: (",  nums2str(xi(count)), ", ", nums2str(yi(count)), ")" ...
                      ), ...
            handles );
        count = count + 1;
    end
catch e
    xi = fix( xi );
    yi = fix( yi );
    ccount = 1;
    %% Set up the compartment image
    for jj = 1:length(xi)
        compartment( UserData.BWCC == UserData.BWCC( yi(jj), xi(jj) ) ) = ccount;
        ccount = ccount + 1;
    end
end

% Create a pseudo-color image of the cells to be analyzed
newView = repmat( mat2gray(UserData.originalImage), [1 1 3] );
newView(:,:,1) = newView(:,:,1) .* .5 + double(compartment > 0) .* 0.5;

% A real count of the cells
realCount = unique( compartment ) - 1;

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

end