%% fun_saveCSV()
% Function to save the data to a CSV file. Rather than use MATLAB's built
% in CSV write function we will explicitly code this line by line.
function fun_saveCSV( data, handles )
% Open the file. w+ flag indicates throw out old contents and write a new
% file completely.
fid = fopen( fullfile( get_outFilenamePath( handles ), get_outFilename( handles ) ), 'w+' );
%% Part 1: Header
fprintf( fid, ...
     "Filename, ID, Area, Filled Area, Perimeter, Major Axis Length, Minor Axis Length, Orientation, Eccentricity\r\n" );

% K seems to be unset, use get_k()
k = get_k( handles );
 
%% Part 2: Iterate line by line
for i = 1:length(data.stats)
    str = strcat( get_inFilename( handles ), ',', ... Input file name
        num2str( i ), ',', ... The ID of the cell were analyzing
        num2str( data.stats(i).Area ), ',', ... Area
        num2str( data.stats(i).FilledArea ), ',', ... FilledArea
        num2str( data.stats(i).Perimeter ), ',', ... Perimeter
        num2str( data.stats(i).MajorAxisLength ), ',', ... MajorAxisLength
        num2str( data.stats(i).MinorAxisLength ), ',', ... MinorAxisLength
        num2str( data.stats(i).Orientation ), ',', ... Orientation
        num2str( data.stats(i).Eccentricity ), ... Eccentricity
        "\r\n" );
    fprintf( fid, str );
end

fclose( fid );