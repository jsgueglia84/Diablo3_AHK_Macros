﻿;=========================================
; 暗黑III猎魔人暗影飞刀AHK宏
; v2.11 20190816
; Present by 是梦~` QQ:46317239
;=========================================
#NoEnv
;#Warn, All, StdOut
SetWorkingDir %A_ScriptDir%
SendMode Input
CoordMode, Pixel, Window
#SingleInstance Force
SetTitleMatchMode 2
#WinActivateForce
SetControlDelay 1
SetWinDelay 0
SetKeyDelay -1
SetMouseDelay -1
SetBatchLines -1
#IfWinActive, ahk_class D3 Main Window Class

;技能按键设置
;/////////////////////////////////////////////////////////
global K_DemonHunterVault := 2           ;影轮翻技能，默认2键
global K_DemonHunterShadowPower := 1     ;暗影之力技能，默认1键
global K_DemonHunterVengeance := 3       ;复仇技能，默认3键
global K_DemonHunterFanOfKnives := 4     ;刀扇技能，默认4键

;可自定义的参数
;/////////////////////////////////////////////////////////
P_MsgBoxTimeOut := 0.8              ;提示框超时的时间，单位秒，默认0.8秒
P_AutoMoveInterval := 50            ;自动拾取间隔，默认50毫秒
P_AutoBuyInterval := 50             ;自动购买间隔, 默认50毫秒
P_AutoBuyQuantity := 30             ;自动购买次数，默认30次
;-----------------------------------
P_AutoVengeanceInterval := 60       ;自动施放复仇间隔，默认60毫秒，最低60
P_AutoFanOfKnivesInterval := 60     ;自动施放刀扇间隔，默认60毫秒，最低60

;标志、状态变量（不可修改）
;/////////////////////////////////////////////////////////
All_On := 0                 ;总开关
;开关------------------------
F_AutoMove := 0             ;左键自动拾取开关
F_AutoProtect := 0          ;自动施放保护技能开关（复仇、刀扇）
;状态------------------------
S_RAttack := 0              ;右键自动攻击状态
S_AutoClick := 0            ;左键连点状态


;脚本主体
;/////////////////////////////////////////////////////////
;注册可自定义热键
;Hotkey, ~$%K_DemonHunterVault%, doVault

;右下角菜单
Menu, Tray, NoStandard
Menu, Tray, Add, 说明
Menu, Tray, Add
Menu, Tray, Standard

;说明窗口
说明:
Gui Font, Bold
Gui Add, GroupBox, x10 y10 w500 h50, 键位设置
Gui Font
Gui Font, Bold cBlue
Gui Add, Text, x25 y26 w480 h23 +0x200, 1：暗影之力、2：影轮翻、3：复仇、4：刀扇、左：战宠、右：暗影飞刀
Gui Font
Gui Font, Bold
Gui Add, GroupBox, x10 y70 w500 h250, 热键设置
Gui Font
Gui Add, Text, x20 y90 w480 h20 +0x200, ·F1：开启/关闭宏功能（默认关闭，运行后需手动开启）
Gui Add, Text, x20 y115 w480 h20 +0x200, ·F2：暂停/继续宏功能；·F7：退出脚本
Gui Add, Text, x20 y140 w480 h20 +0x200, ·F3：自动购买[30]次装备（鼠标指针放到要购买的装备上）
Gui Add, Text, x20 y165 w480 h20 +0x200, ·[2]键：暗影飞刀接影轮翻（非自动攻击时）、影轮翻（自动攻击时）
Gui Add, Text, x20 y190 w480 h20 +0x200, ·上滚轮：同上
Gui Add, Text, x20 y215 w480 h20 +0x200, ·下滚轮：开始持续右键技能攻击（暗影飞刀）
Gui Add, Text, x20 y240 w480 h20 +0x200, ·右键：停止右键技能攻击
Gui Add, Text, x20 y265 w480 h20 +0x200, ·前进（侧）/中键：点击立即施放1次暗影之力，自动循环施放复仇、刀扇，再次点击停止
Gui Add, Text, x20 y290 w480 h20 +0x200, ·后退（侧）/[~]键：点击后开始移动/拾取（需要鼠标配合移动），再次点击停止
Gui Font, Bold cRed
Gui Add, Text, x15 y325 w480 h20 +0x200, 注意：如需在游戏中使用上下滚轮，必须先关闭宏功能！
Gui Font
Gui -MinimizeBox -MaximizeBox
Gui Show, w520 h350, 暗黑III猎魔人暗影飞刀AHK宏v2.11（是梦~`` QQ:46317239）
Return

Gosub, 说明


;通用函数
;/////////////////////////////////////////////////////////
;显示一个在指定时间内自动消失的提示框
showMsg(content) {
    global P_MsgBoxTimeOut
    MsgBox 64, 消息, %content%, %P_MsgBoxTimeOut%
}

autoFunction(func, interval) {
    SetTimer, %func%, %interval%
}

stopAutoFunction(func) {
    SetTimer, %func%, Off
}


;技能操作
;/////////////////////////////////////////////////////////
;鼠标左键点击
doLClick() {
    Click, Left, 1
}

;鼠标左键连点
autoLClick(pressShift, interval) {
    If (pressShift = 1 && !GetKeyState("Shift")) {
        Send, {Shift Down}
    }
    Else If (pressShift = 0 && GetKeyState("Shift")) {
        Send, {Shift Up}
    }
    autoFunction("doLClick", interval)
    global S_AutoClick := 1
}

;停止鼠标左键连点
stopAutoLClick(keepState := 0) {
    If (!keepState) {
        stopAutoFunction("doLClick")
    }
    If (GetKeyState("Shift")) {
        Send, {Shift Up}
    }
    global S_AutoClick := 0, F_AutoMove := 0
}

;鼠标右键攻击（按下）
doRAttack() {
    Click, Down, Right
    global S_RAttack := 1
}

;停止鼠标右键攻击（松开）
stopRAttack() {
    Click, Up, Right
    global S_RAttack := 0
}

;药水
doPotion() {
    Send, {q}
}

;暗影之力
doShadowPower() {
    Send, {%K_DemonHunterShadowPower%}
}

;影轮翻
doVault() {
    Send, {%K_DemonHunterVault%}
}

;复仇
doVengeance() {
    Send, {%K_DemonHunterVengeance%}
}

;刀扇
doKnives() {
    Send, {%K_DemonHunterFanOfKnives%}
}

;停止自动施放保护技能
stopAutoProtect() {
    stopAutoFunction("doVengeance")
    stopAutoFunction("doKnives")
    global F_AutoProtect := 0
}


;功能标签
;/////////////////////////////////////////////////////////
;什么都不做，用于强制跳出循环
void:
return

;在启动宏功能时执行
OnStart:
;...
return

;在停止宏功能时执行
OnStop: 
;...
return


;热键&宏
;/////////////////////////////////////////////////////////
;*****************************
;热键：【F1】
;功能：开启或关闭宏功能
;*****************************
$F1::
All_On := !All_On
If (All_On) {
    Gosub, OnStart
    showMsg("Macro On")
}
Else {
    If (S_AutoClick) {
        stopAutoLClick(0)
    }
    If (S_RAttack) {
        stopRAttack()
    }
    If (F_AutoProtect) {
        stopAutoProtect()
    }
    Gosub, OnStop
    showMsg("Macro Off")
}
return

;*****************************
;热键：【F3】
;功能：一键购买装备
;*****************************
$F3:: 
If (All_On) {
    If (S_AutoClick) {
        stopAutoLClick(0)
    }
    If (S_RAttack) {
        stopRAttack()
    }
    Loop, %P_AutoBuyQuantity% {
        Click, Right, 1
        Sleep, %P_AutoBuyInterval%
    }
}
return

;*****************************
;热键：【上滚轮】、【2键】
;功能：攻击状态时，施放影轮翻；非攻击状态时，施放暗影飞刀+影轮翻
;*****************************
$*2::
~$*WheelUp::
ImprovedVault:
If (All_On &&!S_RAttack) {
    If (F_AutoMove) {
        Click, Right, 1
        Sleep, 200
    }
    Else If (GetKeyState("LButton")) {
        Click, Left, , Up
        Click, Right, 1
        Sleep, 200
        Click, Left, , Down
    }
    Else {
        If (!GetKeyState("RButton")) {
            Click, Right, 1
        }
    }
    doVault()
}
Else {
    doVault()
}
return

;*****************************
;热键：【下滚轮】
;功能：开始鼠标右键攻击
;*****************************
~$*WheelDown::
If (All_On && !S_RAttack) {
    If (S_AutoClick) {
        stopAutoLClick(0)
    }
    ;防止左右键冲突
    If (GetKeyState("LButton")) {
        Click, Left, , Up
    }
    doRAttack()
}
return

;*****************************
;热键：【右键】主动点击鼠标右键时
;功能：停止鼠标右键攻击
;*****************************
~$RButton::
If (All_On && S_RAttack) {
    stopRAttack()
}
return

;*****************************
;热键：【`键】数字1前面的键、【后退】鼠标侧键
;功能：开启、关闭自动移动/拾取
;*****************************
~$`::
$XButton1::
If (All_On) {
    F_AutoMove := !F_AutoMove
    If (F_AutoMove) {
        If (S_RAttack) {
            stopRAttack()
        }
        autoLClick(0, P_AutoMoveInterval)
    }
    Else {
        stopAutoLClick(0)
    }
}
return

;*****************************
;热键：【中键】滚轮、【前进】鼠标侧键
;功能：开启、关闭自动保持复仇、刀扇状态
;*****************************
$MButton::
$XButton2::
If (All_On) {
    F_AutoProtect := !F_AutoProtect
    If (F_AutoProtect) {
        doShadowPower()
        autoFunction("doVengeance", P_AutoVengeanceInterval)
        autoFunction("doKnives", P_AutoFanOfKnivesInterval)
    }
    Else {
        stopAutoProtect()
    }
}
return


;*****************************
;热键：【F2】
;功能：暂停/继续
;*****************************
$F2::Pause

;*****************************
;热键：【F7】
;功能：退出脚本
;*****************************
$F7::ExitApp
