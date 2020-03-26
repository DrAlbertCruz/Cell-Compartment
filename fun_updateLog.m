%% FUN_UPDATELOG
% As of version 101, there is a log in the pane which explains the state of
% the software, things that have happened, etc.
function fun_updateLog( sNewText, handleLog )
iLength = strlength(sNewText);
% Step 1: Get the String value from handleLog
sOld = handleLog.String;
% Step 2: Generate the next string
sNew = strcat( sOld, ">> ", datestr(now), ": ", sNewText, newline );
if iLength <= 30 % If it is short, then just display it
else
sNew = strcat( sNew, sOld ); % Append old stuff to the end
% Step 3: Now change the log
set( handleLog, 'String', sNew );
end