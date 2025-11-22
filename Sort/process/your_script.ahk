SetTitleMatchMode, 2
WinWait, TemplateGUI, , 30
if ErrorLevel
    MsgBox, GUI window not found!
else
    WinActivate, TemplateGUI
    Sleep, 500
Send, {Ctrl down} s {Ctrl up}
    Sleep, 1000
    WinClose, TemplateGUI
ExitApp
