%% FUN_UPDATELOG
% As of version 101, there is a log in the pane which explains the state of
% the software, things that have happened, etc.
function fun_updateLog( sNewText, handles )
% Step 1: Get the String value from handleLog
sOld = get( handles.eventLog, 'String' );
sOldSize = length(sOld);

% Step 2: Generate the next string
sNew = cellstr( strcat( newline, datestr(now), ": ", sNewText, newline ) );

% else
if sOldSize > 0
    sNew = [ sNew ; sOld  ]; % Append old stuff to the end
end

% Step 3: Now change the log
set( handles.eventLog, 'String', sNew );
end