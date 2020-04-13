function data = get_data( handles )
% After selecting the cells, the total stats of each cell selected by the
% user are stored in the UserData portion of the selectCells GUI button.
data = get( handles.selectCells, 'UserData' );