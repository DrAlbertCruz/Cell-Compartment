%% FUN_UPDATELOG
% As of version 101, there is a log in the pane which explains the state of
% the software, things that have happened, etc.
function fun_updateLog( sNewText, handleLog )
% Step 1: Get the String value from handleLog
sOld = handleLog.String;
% Step 2: Get the date
sNew = strcat( sOld, datestr(now), ':', sNewText, newline );
% Step 3: Now change the log
set( handleLog, 'String', sNew );
end