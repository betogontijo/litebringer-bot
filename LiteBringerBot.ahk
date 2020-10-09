; This script was created using Pulover's Macro Creator
; www.macrocreator.com

#NoEnv
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Window
SendMode Input
#SingleInstance Force
SetTitleMatchMode 2
DetectHiddenWindows Off
#WinActivateForce
SetControlDelay 1
SetWinDelay 0
SetKeyDelay -1
SetMouseDelay -1
SetBatchLines -1
#MaxThreadsPerHotkey 2

Menu, Tray, Icon, shell32.dll, 44

Gui, Add, Text,, Hunt:
Gui, Add, Text,, Sell:
Gui, Add, Text,, Pause Button:
Gui, Add, Text,, Submit:
Gui, Add, Hotkey, vHuntHotkey ym, F4
Gui, Add, Hotkey, vSellHotkey, F5
Gui, Add, Hotkey, vPauseHotkey, F12
Gui, Add, Button,, Submit
Gui, Show,, Simple Input Example
Goto, ButtonSubmit
return  ; End of auto-execute section. The script is idle until the user does something.

ControlFromPoint(X, Y, WinTitle="", WinText="", ByRef cX="", ByRef cY="", ExcludeTitle="", ExcludeText="")
{
    static EnumChildFindPointProc=0
    if !EnumChildFindPointProc
        EnumChildFindPointProc := RegisterCallback("EnumChildFindPoint","Fast")
    if !(target_window := WinExist(WinTitle, WinText, ExcludeTitle, ExcludeText))
        return false
    
    VarSetCapacity(rect, 16)
    DllCall("GetWindowRect","uint",target_window,"uint",&rect)
    VarSetCapacity(pah, 36, 0)
    NumPut(X + NumGet(rect,0,"int"), pah,0,"int")
    NumPut(Y + NumGet(rect,4,"int"), pah,4,"int")
    DllCall("EnumChildWindows","uint",target_window,"uint",EnumChildFindPointProc,"uint",&pah)
    control_window := NumGet(pah,24) ? NumGet(pah,24) : target_window
    DllCall("ScreenToClient","uint",control_window,"uint",&pah)
    cX:=NumGet(pah,0,"int"), cY:=NumGet(pah,4,"int")
    return control_window
}

; Ported from AutoHotkey::script2.cpp::EnumChildFindPoint()
EnumChildFindPoint(aWnd, lParam)
{
    if !DllCall("IsWindowVisible","uint",aWnd)
        return true
    VarSetCapacity(rect, 16)
    if !DllCall("GetWindowRect","uint",aWnd,"uint",&rect)
        return true
    pt_x:=NumGet(lParam+0,0,"int"), pt_y:=NumGet(lParam+0,4,"int")
    rect_left:=NumGet(rect,0,"int"), rect_right:=NumGet(rect,8,"int")
    rect_top:=NumGet(rect,4,"int"), rect_bottom:=NumGet(rect,12,"int")
    if (pt_x >= rect_left && pt_x <= rect_right && pt_y >= rect_top && pt_y <= rect_bottom)
    {
        center_x := rect_left + (rect_right - rect_left) / 2
        center_y := rect_top + (rect_bottom - rect_top) / 2
        distance := Sqrt((pt_x-center_x)**2 + (pt_y-center_y)**2)
        update_it := !NumGet(lParam+24)
        if (!update_it)
        {
            rect_found_left:=NumGet(lParam+8,0,"int"), rect_found_right:=NumGet(lParam+8,8,"int")
            rect_found_top:=NumGet(lParam+8,4,"int"), rect_found_bottom:=NumGet(lParam+8,12,"int")
            if (rect_left >= rect_found_left && rect_right <= rect_found_right
                && rect_top >= rect_found_top && rect_bottom <= rect_found_bottom)
                update_it := true
            else if (distance < NumGet(lParam+28,0,"double")
                && (rect_found_left < rect_left || rect_found_right > rect_right
                 || rect_found_top < rect_top || rect_found_bottom > rect_bottom))
                 update_it := true
        }
        if (update_it)
        {
            NumPut(aWnd, lParam+24)
            DllCall("RtlMoveMemory","uint",lParam+8,"uint",&rect,"uint",16)
            NumPut(distance, lParam+28, 0, "double")
        }
    }
    return true
}

ControlClick2(X, Y, WinTitle="A", WinText="", ExcludeTitle="", ExcludeText="") 
{
;  lParam := x & 0xFFFF | (y & 0xFFFF) << 16
;  PostMessage, 0x201, , %lParam%, , %WinTitle% ;WM_LBUTTONDOWN 
;  PostMessage, 0x202, , %lParam%, ,  %WinTitle% ;WM_LBUTTONUP 
  hwnd:=ControlFromPoint(X, Y, WinTitle, WinText, cX, cY 
                             , ExcludeTitle, ExcludeText)
  cX *= -1
  cY *= -1
;  MsgBox, %cX% %cY% %X% %Y%
  SendMessage, 0x2A1, 0, cX&0xFFFF | cY<<16,, ahk_id %hwnd% ; WM_MOUSEHOVER
  PostMessage, 0x200, 0, cX&0xFFFF | cY<<16,, ahk_id %hwnd% ; WM_MOUSEMOVE
;  PostMessage, 0x201, 0, cX&0xFFFF | cY<<16,, ahk_id %hwnd% ; WM_LBUTTONDOWN 
;  PostMessage, 0x202, 0, cX&0xFFFF | cY<<16,, ahk_id %hwnd% ; WM_LBUTTONUP 
  SendMessage, 0x203, 0, cX&0xFFFF | cY<<16,, ahk_id %hwnd% ; WM_LBUTTONDBLCLCK 
  SendMessage, 0x202, 0, cX&0xFFFF | cY<<16,, ahk_id %hwnd% ; WM_LBUTTONUP 
} 

ButtonSubmit: ; disable the old hotkey before adding a new one
;-------------------------------------------------------------------------------
    if HuntHotkey
        Hotkey, %HuntHotkey%, Hunt, Off
    GuiControlGet, HuntHotkey
    if HuntHotkey
        Hotkey, %HuntHotkey%, Hunt

    if SellHotkey
        Hotkey, %SellHotkey%, Sell, Off
    GuiControlGet, SellHotkey
    if SellHotkey
        Hotkey, %SellHotkey%, Sell

    if PauseHotkey
        Hotkey, %PauseHotkey%, Pause, Off
    GuiControlGet, PauseHotkey
    if PauseHotkey
        Hotkey, %PauseHotkey%, Pause
return

GuiClose:
ExitApp

Hunt:
failureCount := 0
WinActivate, LiteBringer ahk_class UnityWndClass
Loop
{
    found := false
    Sleep, 333
    WinGetActiveStats, Title, Width, Height, X, Y
    if (Title != "LiteBringer") {
        Sleep, 1000
        Continue
    }
    CoordMode, Pixel, Window
    ImageSearch, FoundX, FoundY, 0, 0, %Width%, %Height%, .\RegularLoot.png
    If ErrorLevel = 0
    {
        found := true
        SendEvent, {Click, %FoundX%, %FoundY%, 0}
        Sleep, 10
        SendEvent, {Click, Rel 100, 0, 0}
        Sleep, 10
        SendEvent, {Click, Left, 1, }
        Sleep, 500
    }
    CoordMode, Pixel, Window
    ImageSearch, FoundX, FoundY, 0, 0, %Width%, %Height%, .\DiamondLoot.png
    If ErrorLevel = 0
    {
        found := true
        SendEvent, {Click, %FoundX%, %FoundY%, 0}
        Sleep, 10
        SendEvent, {Click, Rel 100, 0, 0}
        Sleep, 10
        SendEvent, {Click, Left, 1, }
        Sleep, 500
    }
    CoordMode, Pixel, Window
    ImageSearch, FoundX, FoundY, 0, 0, %Width%, %Height%, .\Cancel.png
    If ErrorLevel = 0
    {
        SendEvent, {Click, %FoundX%, %FoundY%, 0}
        Sleep, 10
        SendEvent, {Click, Left, 1, }
        Sleep, 100
    }
    CoordMode, Pixel, Window
    ImageSearch, FoundX, FoundY, 0, 0, %Width%, %Height%, .\SendQuest.png
    If ErrorLevel = 0
    {
        found := true
        SendEvent, {Click, %FoundX%, %FoundY%, 0}
        Sleep, 10
        SendEvent, {Click, Left, 1, }
        Sleep, 100
    }
    CoordMode, Pixel, Window
    ImageSearch, FoundX, FoundY, 0, 0, %Width%, %Height%, .\Confirm.png
    If ErrorLevel = 0
    {
        found := true
        SendEvent, {Click, %FoundX%, %FoundY%, 0}
        Sleep, 10
        SendEvent, {Click, Left, 1, }
        Sleep, 100
    }
    CoordMode, Pixel, Window
    ImageSearch, FoundX, FoundY, 0, 0, %Width%, %Height%, .\Back.png
    If ErrorLevel = 0
    {
        found := true
        SendEvent, {Click, %FoundX%, %FoundY%, 0}
        Sleep, 10
        SendEvent, {Click, Left, 1, }
        Sleep, 100
    }
    CoordMode, Pixel, Window
    ImageSearch, FoundX, FoundY, 0, 0, %Width%, %Height%, .\Back2.png
    If ErrorLevel = 0
    {
        found := true
        SendEvent, {Click, %FoundX%, %FoundY%, 0}
        Sleep, 10
        SendEvent, {Click, Left, 1, }
        Sleep, 100
    }
    If (!found)
    {
        failureCount += 1
        SendEvent, {Click, 600, 200, 0}
        Sleep, 10
        Loop, 5
        {
            SendEvent, {Click, WheelDown, 1}
            Sleep, 10
        }
        CoordMode, Pixel, Window
        ImageSearch, FoundX, FoundY, 0, 0, %Width%, %Height%, .\RegularLoot.png
        If ErrorLevel = 0
        {
        }
        Else
        {
            If failureCount >= 10
            {
                failureCount := 0
                SendEvent, {Click, 600, 200, 0}
                Sleep, 10
                Loop, 50
                {
                    Click, WheelUp, 1
                    Sleep, 10
                }
            }
        }
    }
    Else
    {
        failureCount := 0
    }
    CoordMode, Pixel, Window
    ImageSearch, FoundX, FoundY, 0, 0, %Width%, %Height%, .\Ok.png
    If ErrorLevel = 0
    {
        SendEvent, {Click, %FoundX%, %FoundY%, 0}
        Sleep, 10
        SendEvent, {Click, Left, 1, }
        Sleep, 10
    }
    Sleep, 200
}
Return

Sell:
activewindow := "LiteBringer ahk_class UnityWndClass"
failureCount := 0
WinActivate, %activewindow%
Loop
{
    Sleep, 333
    WinGetActiveStats, Title, Width, Height, X, Y
    if (Title != "LiteBringer") {
        Sleep, 1000
        Continue
    }
    CoordMode, Pixel, Window
    ImageSearch, FoundX, FoundY, 0, 0, %Width%, %Height%, .\Confirm.png
    If ErrorLevel = 0
    {
        SendEvent, {Click, %FoundX%, %FoundY%, 0}
        Sleep, 10
        ControlClick2(%FoundX%, %FoundY%, activewindow)
        Sleep, 500
    }
    CoordMode, Pixel, Window
    ImageSearch, FoundX, FoundY, 0, 0, %Width%, %Height%, .\Ok.png
    If ErrorLevel = 0
    {
        SendEvent, {Click, %FoundX%, %FoundY%, 0}
        Sleep, 10
        ControlClick2(%FoundX%, %FoundY%, activewindow)
        Loop, 10
        {
            Sleep, 500
            CoordMode, Pixel, Window
            ImageSearch, FoundX, FoundY, 0, 0, %Width%, %Height%, .\DismantleConfirm.png
            If ErrorLevel = 0
            {
                SendEvent, {Click, %FoundX%, %FoundY%, 0}
                Sleep, 10
                ControlClick2(%FoundX%, %FoundY%, activewindow)
                Sleep, 500
                Break
            }
        }
    }
    CoordMode, Pixel, Window
    ImageSearch, FoundX, FoundY, 0, 0, %Width%, %Height%, .\Dismantle.png
    If ErrorLevel = 0
    {
        SendEvent, {Click, %FoundX%, %FoundY%, 0}
        Sleep, 10
        ControlSend, ahk_parent, {Click, %FoundX%, %FoundY%, 0}, %activewindow%
        ControlClick2(%FoundX%, %FoundY%, activewindow)
        Sleep, 500
    }
    CoordMode, Pixel, Window
    ImageSearch, FoundX, FoundY, 0, 0, %Width%, %Height%, .\Item.png
    If ErrorLevel = 0
    {
        SendEvent, {Click, %FoundX%, %FoundY%, 0}
        Sleep, 10
        ControlClick2(%FoundX%, %FoundY%, activewindow)
        SendEvent, {Click, Left, 1, }
        Sleep, 500
    }
}
Return

Pause:
Pause
Return