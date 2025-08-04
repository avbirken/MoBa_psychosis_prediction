% Make some family designs
% Family 1: case
% Family 2: control
% Family 3: control | control
% Family 4: case | control
% Family 5: case | control | case

pid     = {'F1', 'F2', 'F3', 'F3', 'F4', 'F4', 'F5', 'F5', 'F5'};
iid     = strcat({'I_'}, num2str((1:9)'));
status  = [1, 0, 0, 0, 1, 0, 1, 0, 1];

[trainIDX, testIDX, cv] = makeCV(pid, status, 5, 10);