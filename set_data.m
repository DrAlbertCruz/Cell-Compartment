function set_data( handles, data )
% After selecting the cells, the total stats of each cell selected by the
% user are stored in the UserData portion of the selectCells GUI button.
set( handles.selectCells, 'UserData', data );