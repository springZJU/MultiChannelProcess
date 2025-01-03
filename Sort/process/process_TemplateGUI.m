% AutoHotkey脚本的内容
ahkScript = [...
    'SetTitleMatchMode, 2', newline, ...
    'WinWait, TemplateGUI, , 30', newline, ...
    'if ErrorLevel', newline, ...
    '    MsgBox, GUI window not found!', newline, ...
    'else', newline, ...
    '    WinActivate, TemplateGUI', newline, ...
    '    Sleep, 500', newline, ...
    'Send, {Ctrl down} s {Ctrl up}', newline, ...
    '    Sleep, 1000', newline, ...
    '    WinClose, TemplateGUI', newline, ...
    'ExitApp', newline, ...
];

% 指定AutoHotkey脚本的文件路径
ahkScriptFilePath = 'your_script.ahk';

% 将AHK脚本写入文件
fileID = fopen(ahkScriptFilePath, 'w');
fprintf(fileID, ahkScript);
fclose(fileID);
%%
system('start cmd /c phy template-gui params.py');
% system('phy template-gui params.py');
% 构建AutoHotkey运行命令
ahkExecutablePath = '"C:\Program Files\AutoHotkey\AutoHotkey.exe"';
runAhkCommand = [ahkExecutablePath, ' ', ahkScriptFilePath];
% 运行AutoHotkey脚本
system(runAhkCommand);

pause(10);
delete(".\your_script.ahk");

