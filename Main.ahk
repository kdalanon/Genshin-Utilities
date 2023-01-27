if !(A_IsAdmin)
{
	Run, *RunAs "%A_ScriptFullPath%"
}
#SingleInstance Force
#MaxThreadsPerHotkey 9999; Set a high value to activate the hotkey again while performing a loop
#MaxHotkeysPerInterval 9999
#NoEnv
DetectHiddenWindows, On
SetTitleMatchMode, 2

/*
====================================================
Variable Initialization
====================================================
*/

AutoAttack := "Off"
AutoRun := "Off"
AutoLoot := "Off"
AnimationCancel := "Off"
SkillTimerGUI := "Show"
SkillTimerGUIStatus := "Open"
SkillTimerConfig := "Closed"
ElementsGUIStatus := "Closed"
ElementalSight := "Off"

/*
====================================================
Tray Menu
====================================================
*/

Menu, Tray, Icon, %A_ScriptDir%\Main.ico
Menu, Tray, NoStandard
Menu, Tray, Add, Debug
Menu, Tray, Add, Reload
Menu, Tray, Add, SkillTimerConfig
Menu, Tray, Add, SkillTimerStatus
Menu, Tray, Rename, Reload, &Reload Script (CTRL + ALT + R)
Menu, Tray, Rename, SkillTimerConfig, Configure skill timers (F10)
Menu, Tray, Rename, SkillTimerStatus, Close skill timer indicators

AnimationCancellingToggleTrayMenu:
; Create the last menu first, 'CharacterAnimationCancellingTrayToggle' is the label to be executed when you click the item
Menu, AnimationCancellingOn, Add, Barbara, BarbaraAnimationCancellingTrayToggle, +Radio
Menu, AnimationCancellingOn, Add, Kaeya, KaeyaAnimationCancellingTrayToggle, +Radio
Menu, AnimationCancellingOn, Add, Fischl, FischlAnimationCancellingTrayToggle, +Radio
Menu, AnimationCancellingOn, Add, Amber, AmberAnimationCancellingTrayToggle, +Radio
Menu, AnimationCancellingOn, Add, Ningguang, NingguangAnimationCancellingTrayToggle, +Radio
Menu, AnimationCancellingOn, Add, Timbersaw, TimbersawTrayToggle, +Radio

; Then attach it to the second menu as you create it
Menu, AnimationCancellingToggle, Add, On, :AnimationCancellingOn, +Radio
Menu, AnimationCancellingToggle, Add, Off,, +Radio

; Add this stack to the tray, 'Tray' is a special descriptor
Menu, Tray, Add, Normal Attack Animation Cancel, :AnimationCancellingToggle
Menu, AnimationCancellingToggle, Check, Off

Menu, Tray, Add, Exit
Menu, Tray, Rename, Exit, E&xit Script

/*
====================================================
Skill cooldown timer function
====================================================
*/

RunCharacterTimerScripts()

Loop, 4
{
	WinWait, Character%A_Index%
	GroupAdd, SkillTimerScripts, Character Skill Timer Scripts\Character%A_Index%.ahk
	PartySlot%A_Index%occupied := "No"
	IniRead, SavedCharacterSlot%A_Index%, Character Skill Timer Scripts\Config.ini, Characters, SavedCharacterSlot%A_Index%
}

IniRead, SlowingWater, Character Skill Timer Scripts\Config.ini, Options, %SlowingWater%

; GUI creation
Gui, Main:-Caption
Gui, Main:Color, 0x333333 ; Dark background; same as Visual Studio Code Dark+ (default dark) theme - far left side
Gui, Main:Font, cWhite S10
Gui, Main:Add, Text, x10, Press F10 to show / hide this window
Gui, Main:Add, Text, x10 yp+30, Press F11 ingame to show / hide skill timers
Gui, Main:Add, Picture, vCloseMainGUI gCloseMainGUI xp+355 yp-30, Icons\GUI\Close.png
Gui, Main:Add, Text, x10 yp+60, Current Party

; Party slots
Gui, Main:Add, Picture, vPartySlot1 gPartySlot1 x10 yp+40, Icons\Party Slots\PartySlot1.png
Gui, Main:Add, Picture, vPartySlot2 gPartySlot2 xp+100, Icons\Party Slots\PartySlot2.png
Gui, Main:Add, Picture, vPartySlot3 gPartySlot3 xp+100, Icons\Party Slots\PartySlot3.png
Gui, Main:Add, Picture, vPartySlot4 gPartySlot4 xp+100, Icons\Party Slots\PartySlot4.png

; 1st row
Gui, Main:Add, Text, x10 yp+160, Available Party
Gui, Main:Add, Picture, vAmber gAmber x10 yp+40, Icons\Characters\Amber.png
Gui, Main:Add, Picture, vBarbara gBarbara xp+100, Icons\Characters\Barbara.png
Gui, Main:Add, Picture, vFischl gFischl xp+100, Icons\Characters\Fischl.png
Gui, Main:Add, Picture, vKaeya gKaeya xp+100, Icons\Characters\Kaeya.png
Gui, Main:Add, Text, vAmberText x30 yp+90, Amber
Gui, Main:Add, Text, vBarbaraText xp+95, Barbara
Gui, Main:Add, Text, vFischlText xp+108, Fischl
Gui, Main:Add, Text, vKaeyaText xp+97, Kaeya

; 2nd row
Gui, Main:Add, Picture, vXiangling gXiangling x10 yp+40, Icons\Characters\Xiangling.png
Gui, Main:Add, Picture, vAether gAether xp+100, Icons\Characters\Aether.png
Gui, Main:Add, Picture, vNingguang gNingguang xp+100, Icons\Characters\Ningguang.png
Gui, Main:Add, Picture, vLisa gLisa xp+100, Icons\Characters\Lisa.png
Gui, Main:Add, Text, vXianglingText x22 yp+90, Xiangling
Gui, Main:Add, Text, vAetherText xp+108, Aether
Gui, Main:Add, Text, vNingguangText xp+86, Ningguang
Gui, Main:Add, Text, vLisaText xp+121, Lisa

; 3rd row
Gui, Main:Add, Picture, vDiona gDiona x10 yp+40, Icons\Characters\Diona.png
Gui, Main:Add, Picture, vBeidou gBeidou xp+100, Icons\Characters\Beidou.png
Gui, Main:Add, Text, vDionaText x32 yp+90, Diona
Gui, Main:Add, Text, vBeidouText xp+96, Beidou

; Buttons
Gui, Main:Add, Checkbox, vSlowingWater xp-110 yp+40, Spiral Abyss Slowing Water (250`% skill cooldown increase)
Switch SlowingWater
{
	Case "SlowingWater=1": GuiControl, Main:, SlowingWater, 1
	Case "SlowingWater=0": GuiControl, Main:, SlowingWater, 0
}
Gui, Main:Add, Button, gMainButtonOK x20 yp+50 w80, OK
Gui, Main:Add, Button, gMainButtonReset xp+285 w80, Reset
Gui, Main:Add, Picture, vSettings gGUISettings xp-115 yp+2, Icons\GUI\Settings.png

OnMessage(0x200,"WM_MOUSEHOVER")

Loop, 4
{
	if (SavedCharacterSlot%A_Index% != "")
	{
		Gosub, % SavedCharacterSlot%A_Index%
	}
}

TrayTip, Genshin Utilities, Script loaded
return

/*
====================================================
Tray Menu Functions
====================================================
*/

Debug:
ListLines
return

Reload:
^!r::
Reload
return

SkillTimerConfig:
F10::
Switch SkillTimerConfig
{
	Case "Closed": SkillTimerConfigShow()
	Case "Open": SkillTimerConfigHide()
}
return

SkillTimerStatus:
Switch SkillTimerGUIStatus
{
	Case "Open":
		GroupClose, SkillTimerScripts, A
		Menu, Tray, Rename, Close skill timer indicators, Open skill timer indicators
		SkillTimerGUIStatus := "Closed"
	Case "Closed":
		RunCharacterTimerScripts()
		Menu, Tray, Rename, Open skill timer indicators, Close skill timer indicators
		SkillTimerGUIStatus := "Open"
}
return

Exit:
GroupClose, SkillTimerScripts, A
ExitApp

BarbaraAnimationCancellingTrayToggle:
Menu, AnimationCancellingOn, Check, Barbara
Menu, AnimationCancellingOn, Uncheck, Kaeya
Menu, AnimationCancellingOn, Uncheck, Fischl
Menu, AnimationCancellingOn, Uncheck, Amber
Menu, AnimationCancellingOn, Uncheck, Ningguang
Menu, AnimationCancellingOn, Uncheck, Timbersaw
Menu, AnimationCancellingToggle, Uncheck, Off
Menu, AnimationCancellingToggle, Check, On
Hotkey, CapsLock, BarbaraAnimationCancelling, On
WinActivate, ahk_class UnityWndClass
return

KaeyaAnimationCancellingTrayToggle:
Menu, AnimationCancellingOn, Uncheck, Barbara
Menu, AnimationCancellingOn, Check, Kaeya
Menu, AnimationCancellingOn, Uncheck, Fischl
Menu, AnimationCancellingOn, Uncheck, Amber
Menu, AnimationCancellingOn, Uncheck, Ningguang
Menu, AnimationCancellingOn, Uncheck, Timbersaw
Menu, AnimationCancellingToggle, Uncheck, Off
Menu, AnimationCancellingToggle, Check, On
Hotkey, CapsLock, KaeyaAnimationCancelling, On
WinActivate, ahk_class UnityWndClass
return

FischlAnimationCancellingTrayToggle:
Menu, AnimationCancellingOn, Uncheck, Barbara
Menu, AnimationCancellingOn, Uncheck, Kaeya
Menu, AnimationCancellingOn, Check, Fischl
Menu, AnimationCancellingOn, Uncheck, Amber
Menu, AnimationCancellingOn, Uncheck, Ningguang
Menu, AnimationCancellingOn, Uncheck, Timbersaw
Menu, AnimationCancellingToggle, Uncheck, Off
Menu, AnimationCancellingToggle, Check, On
Hotkey, CapsLock, FischlAnimationCancelling, On
WinActivate, ahk_class UnityWndClass
return

AmberAnimationCancellingTrayToggle:
Menu, AnimationCancellingOn, Uncheck, Barbara
Menu, AnimationCancellingOn, Uncheck, Kaeya
Menu, AnimationCancellingOn, Uncheck, Fischl
Menu, AnimationCancellingOn, Check, Amber
Menu, AnimationCancellingOn, Uncheck, Ningguang
Menu, AnimationCancellingOn, Uncheck, Timbersaw
Menu, AnimationCancellingToggle, Uncheck, Off
Menu, AnimationCancellingToggle, Check, On
Hotkey, CapsLock, AmberAnimationCancelling, On
WinActivate, ahk_class UnityWndClass
return

NingguangAnimationCancellingTrayToggle:
Menu, AnimationCancellingOn, Uncheck, Barbara
Menu, AnimationCancellingOn, Uncheck, Kaeya
Menu, AnimationCancellingOn, Uncheck, Fischl
Menu, AnimationCancellingOn, Uncheck, Amber
Menu, AnimationCancellingOn, Check, Ningguang
Menu, AnimationCancellingOn, Uncheck, Timbersaw
Menu, AnimationCancellingToggle, Uncheck, Off
Menu, AnimationCancellingToggle, Check, On
Hotkey, CapsLock, NingguangAnimationCancelling, On
WinActivate, ahk_class UnityWndClass
return

TimbersawTrayToggle:
Menu, AnimationCancellingOn, Uncheck, Barbara
Menu, AnimationCancellingOn, Uncheck, Kaeya
Menu, AnimationCancellingOn, Uncheck, Fischl
Menu, AnimationCancellingOn, Uncheck, Amber
Menu, AnimationCancellingOn, Uncheck, Ningguang
Menu, AnimationCancellingOn, Check, Timbersaw
Menu, AnimationCancellingToggle, Uncheck, Off
Menu, AnimationCancellingToggle, Check, On
Hotkey, CapsLock, Timbersaw, On
WinActivate, ahk_class UnityWndClass
return

Off:
Menu, AnimationCancellingOn, Uncheck, Barbara
Menu, AnimationCancellingOn, Uncheck, Kaeya
Menu, AnimationCancellingOn, Uncheck, Fischl
Menu, AnimationCancellingOn, Uncheck, Amber
Menu, AnimationCancellingOn, Uncheck, Ningguang
Menu, AnimationCancellingOn, Uncheck, Timbersaw
Menu, AnimationCancellingToggle, Uncheck, On
Menu, AnimationCancellingToggle, Check, Off
Hotkey, CapsLock,, Off
WinActivate, ahk_class UnityWndClass
return

/*
====================================================
Functions
====================================================
*/

RunCharacterTimerScripts()
{
	Loop, 4
	{
		Run, Character Skill Timer Scripts\Character%A_Index%.ahk
	}
}

SkillTimerConfigShow()
{
	Global
	Gui, Main:Show, AutoSize
	SkillTimerConfig := "Open"
	DllCall("SetFocus", "Ptr", 0)
}

SkillTimerConfigHide()
{
	Global
	Gui, Main:Hide
	SkillTimerConfig := "Closed"
}

ElementsGUIHide()
{
	Global
	Gui, AetherElements:Destroy
	ElementsGUIStatus := "Closed"
}

WM_MOUSEHOVER()
{
	Global
	Cursor := DllCall("LoadCursor", "uint", 0, "uint", 32649) ; Hand cursor
	if A_GuiControl contains Amber,Barbara,Fischl,Kaeya,Xiangling,Aether,AetherAnemo,AetherGeo,AetherElectro,Ningguang,Lisa,Diona,Beidou
	{
		DllCall("SetCursor", "uint", Cursor)
	} else if A_GuiControl contains PartySlot1,PartySlot2,PartySlot3,PartySlot4
	{
		if (A_GuiControl = "PartySlot1" AND PartySlot1occupied = "Yes")
		or (A_GuiControl = "PartySlot2" AND PartySlot2occupied = "Yes")
		or (A_GuiControl = "PartySlot3" AND PartySlot3occupied = "Yes")
		or (A_GuiControl = "PartySlot4" AND PartySlot4occupied = "Yes")
		{
			DllCall("SetCursor", "uint", Cursor)
		}
	}
}

/*
====================================================
Skill Timer Indicators
====================================================
*/

GUISettings:
MsgBox, Settings go here
return

Amber:
Loop, 4
{
	if (PartySlot%A_Index%occupied = "No")
	{
		GuiControlGet, AmberTextOriginalPos, Main:Pos, AmberText
		GuiControl, Main:, Amber
		GuiControl, Main:, PartySlot%A_Index%, Icons\Characters\Amber.png
		Switch A_Index
		{
			Case "1": GuiControl, Main:Move, AmberText, % "x30 y200"
			Case "2": GuiControl, Main:Move, AmberText, % "x130 y200"
			Case "3": GuiControl, Main:Move, AmberText, % "x230 y200"
			Case "4": GuiControl, Main:Move, AmberText, % "x330 y200"
		}
		SavedCharacterSlot%A_Index% := "Amber"
		PartySlot%A_Index%occupied := "Yes"
		Break
	} 
}
return

Barbara:
Loop, 4
{
	if (PartySlot%A_Index%occupied = "No")
	{
		GuiControlGet, BarbaraTextOriginalPos, Main:Pos, BarbaraText
		GuiControl, Main:, Barbara
		GuiControl, Main:, PartySlot%A_Index%, Icons\Characters\Barbara.png
		Switch A_Index
		{
			Case "1": GuiControl, Main:Move, BarbaraText, % "x25 y200"
			Case "2": GuiControl, Main:Move, BarbaraText, % "x125 y200"
			Case "3": GuiControl, Main:Move, BarbaraText, % "x225 y200"
			Case "4": GuiControl, Main:Move, BarbaraText, % "x325 y200"
		}
		SavedCharacterSlot%A_Index% := "Barbara"
		PartySlot%A_Index%occupied := "Yes"
		Break
	} 
}
return

Fischl:
Loop, 4
{
	if (PartySlot%A_Index%occupied = "No")
	{
		GuiControlGet, FischlTextOriginalPos, Main:Pos, FischlText
		GuiControl, Main:, Fischl
		GuiControl, Main:, PartySlot%A_Index%, Icons\Characters\Fischl.png
		Switch A_Index
		{
			Case "1": GuiControl, Main:Move, FischlText, % "x32 y200"
			Case "2": GuiControl, Main:Move, FischlText, % "x132 y200"
			Case "3": GuiControl, Main:Move, FischlText, % "x232 y200"
			Case "4": GuiControl, Main:Move, FischlText, % "x332 y200"
		}
		SavedCharacterSlot%A_Index% := "Fischl"
		PartySlot%A_Index%occupied := "Yes"
		Break
	}
}
return

Kaeya:
Loop, 4
{
	if (PartySlot%A_Index%occupied = "No")
	{
		GuiControlGet, KaeyaTextOriginalPos, Main:Pos, KaeyaText
		GuiControl, Main:, Kaeya
		GuiControl, Main:, PartySlot%A_Index%, Icons\Characters\Kaeya.png
		Switch A_Index
		{
			Case "1": GuiControl, Main:Move, KaeyaText, % "x30 y200"
			Case "2": GuiControl, Main:Move, KaeyaText, % "x130 y200"
			Case "3": GuiControl, Main:Move, KaeyaText, % "x230 y200"
			Case "4": GuiControl, Main:Move, KaeyaText, % "x330 y200"
		}
		SavedCharacterSlot%A_Index% := "Kaeya"
		PartySlot%A_Index%occupied := "Yes"
		Break
	}
}
return

Xiangling:
Loop, 4
{
	if (PartySlot%A_Index%occupied = "No")
	{
		GuiControlGet, XianglingTextOriginalPos, Main:Pos, XianglingText
		GuiControl, Main:, Xiangling
		GuiControl, Main:, PartySlot%A_Index%, Icons\Characters\Xiangling.png
		Switch A_Index
		{
			Case "1": GuiControl, Main:Move, XianglingText, % "x22 y200"
			Case "2": GuiControl, Main:Move, XianglingText, % "x122 y200"
			Case "3": GuiControl, Main:Move, XianglingText, % "x222 y200"
			Case "4": GuiControl, Main:Move, XianglingText, % "x322 y200"
		}
		SavedCharacterSlot%A_Index% := "Xiangling"
		PartySlot%A_Index%occupied := "Yes"
		Break
	}
}
return

Aether:
Gui, AetherElements:-Caption
Gui, AetherElements:Color, 0x252526 ; Dark background; same as Visual Studio Code left side
Gui, AetherElements:Font, cWhite S10
Gui, AetherElements:Add, Text, xp+75 yp+10, Choose an element
Gui, AetherElements:Add, Picture, vCloseElementsGUI gCloseElementsGUI xp+175, Icons\GUI\Close.png
Gui, AetherElements:Add, Picture, vAetherAnemo gAetherAnemo x10 yp+40, Icons\Elements\Anemo.png
Gui, AetherElements:Add, Picture, vAetherGeo gAetherGeo xp+100, Icons\Elements\Geo.png
Gui, AetherElements:Add, Picture, vAetherElectro gAetherElectro xp+100, Icons\Elements\Electro.png
Gui, AetherElements:Add, Text, vAetherAnemoText x22 yp+75, Anemo
Gui, AetherElements:Add, Text, vAetherGeoText xp+106, Geo
Gui, AetherElements:Add, Text, vAetherElectroText xp+93, Electro
Gui, AetherElements:Show
ElementsGUIStatus := "Open"
return

AetherAnemo:
Loop, 4
{
	if (PartySlot%A_Index%occupied = "No")
	{
		GuiControlGet, AetherTextOriginalPos, Main:Pos, AetherText
		GuiControlGet, AnemoTextExists, Main:Enabled, AnemoText
		GuiControl, Main:, Aether
		GuiControl, Main:, PartySlot%A_Index%, Icons\Characters\AetherAnemo.png
		Switch A_Index
		{
			Case "1":
				if (AnemoTextExists = "")
				{
					Gui, Main:Add, Text, vAnemoText, (Anemo)
				} else
				{
					GuiControl, Main:Text, AnemoText, (Anemo)
				}
				GuiControl, Main:Show, AnemoText
				GuiControl, Main:Move, AetherText, % "x31 y200"
				GuiControl, Main:Move, AnemoText, % "x25 y220"
			Case "2":
				if (AnemoTextExists = "")
				{
					Gui, Main:Add, Text, vAnemoText, (Anemo)
				} else
				{
					GuiControl, Main:Text, AnemoText, (Anemo)
				}
				GuiControl, Main:Show, AnemoText
				GuiControl, Main:Move, AetherText, % "x131 y200"
				GuiControl, Main:Move, AnemoText, % "x125 y220"
			Case "3":
				if (AnemoTextExists = "")
				{
					Gui, Main:Add, Text, vAnemoText, (Anemo)
				} else
				{
					GuiControl, Main:Text, AnemoText, (Anemo)
				}
				GuiControl, Main:Show, AnemoText
				GuiControl, Main:Move, AetherText, % "x231 y200"
				GuiControl, Main:Move, AnemoText, % "x225 y220"
			Case "4":
				if (AnemoTextExists = "")
				{
					Gui, Main:Add, Text, vAnemoText, (Anemo)
				} else
				{
					GuiControl, Main:Text, AnemoText, (Anemo)
				}
				GuiControl, Main:Show, AnemoText
				GuiControl, Main:Move, AetherText, % "x331 y200"
				GuiControl, Main:Move, AnemoText, % "x325 y220"
		}
		SavedCharacterSlot%A_Index% := "AetherAnemo"
		PartySlot%A_Index%occupied := "Yes"
		ElementsGUIHide()
		Break
	}
}
return

AetherGeo:
ElementsGUIStatus := "Closed"
Loop, 4
{
	if (PartySlot%A_Index%occupied = "No")
	{
		GuiControlGet, AetherTextOriginalPos, Main:Pos, AetherText
		GuiControlGet, GeoTextExists, Main:Enabled, GeoText
		GuiControl, Main:, Aether
		GuiControl, Main:, PartySlot%A_Index%, Icons\Characters\AetherGeo.png
		Switch A_Index
		{
			Case "1":
				if (GeoTextExists = "")
				{
					Gui, Main:Add, Text, vGeoText, (Geo)
				} else
				{
					GuiControl, Main:Text, GeoText, (Geo)
				}
				GuiControl, Main:Show, GeoText
				GuiControl, Main:Move, AetherText, % "x31 y200"
				GuiControl, Main:Move, GeoText, % "x33 y220"
			Case "2":
				if (GeoTextExists = "")
				{
					Gui, Main:Add, Text, vGeoText, (Geo)
				} else
				{
					GuiControl, Main:Text, GeoText, (Geo)
				}
				GuiControl, Main:Show, GeoText
				GuiControl, Main:Move, AetherText, % "x131 y200"
				GuiControl, Main:Move, GeoText, % "x133 y220"
			Case "3":
				if (GeoTextExists = "")
				{
					Gui, Main:Add, Text, vGeoText, (Geo)
				} else
				{
					GuiControl, Main:Text, GeoText, (Geo)
				}
				GuiControl, Main:Show, GeoText
				GuiControl, Main:Move, AetherText, % "x231 y200"
				GuiControl, Main:Move, GeoText, % "x233 y220"
			Case "4":
				if (GeoTextExists = "")
				{
					Gui, Main:Add, Text, vGeoText, (Geo)
				} else
				{
					GuiControl, Main:Text, GeoText, (Geo)
				}
				GuiControl, Main:Show, GeoText
				GuiControl, Main:Move, AetherText, % "x331 y200"
				GuiControl, Main:Move, GeoText, % "x333 y220"
		}
		SavedCharacterSlot%A_Index% := "AetherGeo"
		PartySlot%A_Index%occupied := "Yes"
		ElementsGUIHide()
		Break
	}
}
return

AetherElectro:
Loop, 4
{
	if (PartySlot%A_Index%occupied = "No")
	{
		GuiControlGet, AetherTextOriginalPos, Main:Pos, AetherText
		GuiControlGet, ElectroTextExists, Main:Enabled, ElectroText
		GuiControl, Main:, Aether
		GuiControl, Main:, PartySlot%A_Index%, Icons\Characters\AetherElectro.png
		Switch A_Index
		{
			Case "1":
				if (ElectroTextExists = "")
				{
					Gui, Main:Add, Text, vElectroText, (Electro)
				} else
				{
					GuiControl, Main:Text, ElectroText, (Electro)
				}
				GuiControl, Main:Show, ElectroText
				GuiControl, Main:Move, AetherText, % "x30 y200"
				GuiControl, Main:Move, ElectroText, % "x25 y220"
			Case "2":
				if (ElectroTextExists = "")
				{
					Gui, Main:Add, Text, vElectroText, (Electro)
				} else
				{
					GuiControl, Main:Text, ElectroText, (Electro)
				}
				GuiControl, Main:Show, ElectroText
				GuiControl, Main:Move, AetherText, % "x130 y200"
				GuiControl, Main:Move, ElectroText, % "x125 y220"
			Case "3":
				if (ElectroTextExists = "")
				{
					Gui, Main:Add, Text, vElectroText, (Electro)
				} else
				{
					GuiControl, Main:Text, ElectroText, (Electro)
				}
				GuiControl, Main:Show, ElectroText
				GuiControl, Main:Move, AetherText, % "x230 y200"
				GuiControl, Main:Move, ElectroText, % "x225 y220"
			Case "4":
				if (ElectroTextExists = "")
				{
					Gui, Main:Add, Text, vElectroText, (Electro)
				} else
				{
					GuiControl, Main:Text, ElectroText, (Electro)
				}
				GuiControl, Main:Show, ElectroText
				GuiControl, Main:Move, AetherText, % "x330 y200"
				GuiControl, Main:Move, ElectroText, % "x325 y220"
		}
		SavedCharacterSlot%A_Index% := "AetherElectro"
		PartySlot%A_Index%occupied := "Yes"
		ElementsGUIHide()
		Break
	}
}
return

Ningguang:
Loop, 4
{
	if (PartySlot%A_Index%occupied = "No")
	{
		GuiControlGet, NingguangTextOriginalPos, Main:Pos, NingguangText
		GuiControl, Main:, Ningguang
		GuiControl, Main:, PartySlot%A_Index%, Icons\Characters\Ningguang.png
		Switch A_Index
		{
			Case "1": GuiControl, Main:Move, NingguangText, % "x16 y200"
			Case "2": GuiControl, Main:Move, NingguangText, % "x116 y200"
			Case "3": GuiControl, Main:Move, NingguangText, % "x216 y200"
			Case "4": GuiControl, Main:Move, NingguangText, % "x316 y200"
		}
		SavedCharacterSlot%A_Index% := "Ningguang"
		PartySlot%A_Index%occupied := "Yes"
		Break
	}
}
return

Lisa:
Loop, 4
{
	if (PartySlot%A_Index%occupied = "No")
	{
		GuiControlGet, LisaTextOriginalPos, Main:Pos, LisaText
		GuiControl, Main:, Lisa
		GuiControl, Main:, PartySlot%A_Index%, Icons\Characters\Lisa.png
		Switch A_Index
		{
			Case "1": GuiControl, Main:Move, LisaText, % "x37 y200"
			Case "2": GuiControl, Main:Move, LisaText, % "x137 y200"
			Case "3": GuiControl, Main:Move, LisaText, % "x237 y200"
			Case "4": GuiControl, Main:Move, LisaText, % "x337 y200"
		}
		SavedCharacterSlot%A_Index% := "Lisa"
		PartySlot%A_Index%occupied := "Yes"
		Break
	}
}
return

Diona:
Loop, 4
{
	if (PartySlot%A_Index%occupied = "No")
	{
		GuiControlGet, DionaTextOriginalPos, Main:Pos, DionaText
		GuiControl, Main:, Diona
		GuiControl, Main:, PartySlot%A_Index%, Icons\Characters\Diona.png
		Switch A_Index
		{
			Case "1": GuiControl, Main:Move, DionaText, % "x32 y200"
			Case "2": GuiControl, Main:Move, DionaText, % "x132 y200"
			Case "3": GuiControl, Main:Move, DionaText, % "x232 y200"
			Case "4": GuiControl, Main:Move, DionaText, % "x332 y200"
		}
		SavedCharacterSlot%A_Index% := "Diona"
		PartySlot%A_Index%occupied := "Yes"
		Break
	}
}
return

Beidou:
Loop, 4
{
	if (PartySlot%A_Index%occupied = "No")
	{
		GuiControlGet, BeidouTextOriginalPos, Main:Pos, BeidouText
		GuiControl, Main:, Beidou
		GuiControl, Main:, PartySlot%A_Index%, Icons\Characters\Beidou.png
		Switch A_Index
		{
			Case "1": GuiControl, Main:Move, BeidouText, % "x28 y200"
			Case "2": GuiControl, Main:Move, BeidouText, % "x128 y200"
			Case "3": GuiControl, Main:Move, BeidouText, % "x228 y200"
			Case "4": GuiControl, Main:Move, BeidouText, % "x328 y200"
		}
		SavedCharacterSlot%A_Index% := "Beidou"
		PartySlot%A_Index%occupied := "Yes"
		Break
	}
}
return

PartySlot1:
if (SavedCharacterSlot1 != "" AND PartySlot1occupied = "Yes")
{
	GuiControl, Main:, PartySlot1, Icons\Party Slots\PartySlot1.png
	if (SavedCharacterSlot1 = "AetherAnemo")
	{
		GuiControl, Main:, Aether, Icons\Characters\Aether.png
		GuiControl, Main:Move, AetherText, % "x" AetherTextOriginalPosX " y" AetherTextOriginalPosY
		GuiControl, Main:Hide, AnemoText
	} else if (SavedCharacterSlot1 = "AetherGeo")
	{
		GuiControl, Main:, Aether, Icons\Characters\Aether.png
		GuiControl, Main:Move, AetherText, % "x" AetherTextOriginalPosX " y" AetherTextOriginalPosY
		GuiControl, Main:Hide, GeoText
	} else if (SavedCharacterSlot1 = "AetherElectro")
	{
		GuiControl, Main:, Aether, Icons\Characters\Aether.png
		GuiControl, Main:Move, AetherText, % "x" AetherTextOriginalPosX " y" AetherTextOriginalPosY
		GuiControl, Main:Hide, ElectroText
	} else
	{
		GuiControl, Main:, %SavedCharacterSlot1%, Icons\Characters\%SavedCharacterSlot1%.png
		GuiControl, Main:Move, %SavedCharacterSlot1%Text, % "x" %SavedCharacterSlot1%TextOriginalPosX " y" %SavedCharacterSlot1%TextOriginalPosY
	}
	PartySlot1occupied := "No"
	SavedCharacterSlot1 := ""
}
return

PartySlot2:
if (SavedCharacterSlot2 != "" AND PartySlot2occupied = "Yes")
{
	GuiControl, Main:, PartySlot2, Icons\Party Slots\PartySlot2.png
	if (SavedCharacterSlot2 = "AetherAnemo")
	{
		GuiControl, Main:, Aether, Icons\Characters\Aether.png
		GuiControl, Main:Move, AetherText, % "x" AetherTextOriginalPosX " y" AetherTextOriginalPosY
		GuiControl, Main:Hide, AnemoText
	} else if (SavedCharacterSlot2 = "AetherGeo")
	{
		GuiControl, Main:, Aether, Icons\Characters\Aether.png
		GuiControl, Main:Move, AetherText, % "x" AetherTextOriginalPosX " y" AetherTextOriginalPosY
		GuiControl, Main:Hide, GeoText
	} else if (SavedCharacterSlot2 = "AetherElectro")
	{
		GuiControl, Main:, Aether, Icons\Characters\Aether.png
		GuiControl, Main:Move, AetherText, % "x" AetherTextOriginalPosX " y" AetherTextOriginalPosY
		GuiControl, Main:Hide, ElectroText
	} else
	{
		GuiControl, Main:, %SavedCharacterSlot2%, Icons\Characters\%SavedCharacterSlot2%.png
		GuiControl, Main:Move, %SavedCharacterSlot2%Text, % "x" %SavedCharacterSlot2%TextOriginalPosX " y" %SavedCharacterSlot2%TextOriginalPosY
	}
	PartySlot2occupied := "No"
	SavedCharacterSlot2 := ""
}
return

PartySlot3:
if (SavedCharacterSlot3 != "" AND PartySlot3occupied = "Yes")
{
	GuiControl, Main:, PartySlot3, Icons\Party Slots\PartySlot3.png
	if (SavedCharacterSlot3 = "AetherAnemo")
	{
		GuiControl, Main:, Aether, Icons\Characters\Aether.png
		GuiControl, Main:Move, AetherText, % "x" AetherTextOriginalPosX " y" AetherTextOriginalPosY
		GuiControl, Main:Hide, AnemoText
	} else if (SavedCharacterSlot3 = "AetherGeo")
	{
		GuiControl, Main:, Aether, Icons\Characters\Aether.png
		GuiControl, Main:Move, AetherText, % "x" AetherTextOriginalPosX " y" AetherTextOriginalPosY
		GuiControl, Main:Hide, GeoText
	} else if (SavedCharacterSlot3 = "AetherElectro")
	{
		GuiControl, Main:, Aether, Icons\Characters\Aether.png
		GuiControl, Main:Move, AetherText, % "x" AetherTextOriginalPosX " y" AetherTextOriginalPosY
		GuiControl, Main:Hide, ElectroText
	} else
	{
		GuiControl, Main:, %SavedCharacterSlot3%, Icons\Characters\%SavedCharacterSlot3%.png
		GuiControl, Main:Move, %SavedCharacterSlot3%Text, % "x" %SavedCharacterSlot3%TextOriginalPosX " y" %SavedCharacterSlot3%TextOriginalPosY
	}
	PartySlot3occupied := "No"
	SavedCharacterSlot3 := ""
}
return

PartySlot4:
if (SavedCharacterSlot4 != "" AND PartySlot4occupied = "Yes")
{
	GuiControl, Main:, PartySlot4, Icons\Party Slots\PartySlot4.png
	if (SavedCharacterSlot4 = "AetherAnemo")
	{
		GuiControl, Main:, Aether, Icons\Characters\Aether.png
		GuiControl, Main:Move, AetherText, % "x" AetherTextOriginalPosX " y" AetherTextOriginalPosY
		GuiControl, Main:Hide, AnemoText
	} else if (SavedCharacterSlot4 = "AetherGeo")
	{
		GuiControl, Main:, Aether, Icons\Characters\Aether.png
		GuiControl, Main:Move, AetherText, % "x" AetherTextOriginalPosX " y" AetherTextOriginalPosY
		GuiControl, Main:Hide, GeoText
	} else if (SavedCharacterSlot4 = "AetherElectro")
	{
		GuiControl, Main:, Aether, Icons\Characters\Aether.png
		GuiControl, Main:Move, AetherText, % "x" AetherTextOriginalPosX " y" AetherTextOriginalPosY
		GuiControl, Main:Hide, ElectroText
	} else
	{
		GuiControl, Main:, %SavedCharacterSlot4%, Icons\Characters\%SavedCharacterSlot4%.png
		GuiControl, Main:Move, %SavedCharacterSlot4%Text, % "x" %SavedCharacterSlot4%TextOriginalPosX " y" %SavedCharacterSlot4%TextOriginalPosY
	}
	PartySlot4occupied := "No"
	SavedCharacterSlot4 := ""
}
return

MainButtonOK:
Gui, Submit
FileDelete, Character Skill Timer Scripts\Config.ini
Loop, 4
{
	IniWrite % SavedCharacterSlot%A_Index%, Character Skill Timer Scripts\Config.ini, Characters, SavedCharacterSlot%A_Index%
}
IniWrite % SlowingWater, Character Skill Timer Scripts\Config.ini, Options, SlowingWater
RunCharacterTimerScripts()
SkillTimerConfig := "Closed"
return

MainButtonReset:
Loop, 4
{
	Gosub, PartySlot%A_Index%
}
return

CloseMainGUI:
SkillTimerConfigHide()
return

CloseElementsGUI:
ElementsGUIHide()
return

/*
====================================================
Character Normal Attack Animation Cancels
====================================================
*/

#IfWinActive ahk_class UnityWndClass

; Barbara AutoAttack animation cancelling
BarbaraAnimationCancelling:
KeyWait, CapsLock, L
AutoAttack := "Off"
AutoRun := "Off"
if (AnimationCancel = "Off")
{
	AnimationCancel := "On"
	Loop,
	{
		if (AnimationCancel = "Off")
		{
			break
		} else if !WinActive("ahk_class UnityWndClass")
		{
			AnimationCancel := "Off"
		} else
		{
			Click, Down
			Sleep, 500
			Click, Up
			Sleep, 425
			SendInput, {Space}
			Sleep, 575
		}
	}
} else
{
	AnimationCancel := "Off"
}
Sleep, 250
SetCapsLockState, Off
return

; Kaeya AutoAttack animation cancelling
KaeyaAnimationCancelling:
KeyWait, CapsLock, L
AutoAttack := "Off"
AutoRun := "Off"
if (AnimationCancel = "Off")
{
	AnimationCancel := "On"
	Loop,
	{
		if (AnimationCancel = "Off")
		{
			break
		} else if !WinActive("ahk_class UnityWndClass")
		{
			AnimationCancel := "Off"
		} else
		{
			Click
			Sleep, 350
			Click
			Sleep, 200
			Click, Down
			Sleep, 350
			Click, Up
			Sleep, 200
			Send, {Space}
			Sleep, 500
		}
	}
} else
{
	AnimationCancel := "Off"
}
Sleep, 250
SetCapsLockState, Off
return

; Fischl AutoAttack animation cancelling
FischlAnimationCancelling:
KeyWait, CapsLock, L
SendInput, {w Down}
AutoAttack := "Off"
AutoRun := "Off"
if (AnimationCancel = "Off")
{
	AnimationCancel := "On"
	Loop,
	{
		if (AnimationCancel = "Off")
		{
			SendInput, w
			break
		} else if !WinActive("ahk_class UnityWndClass")
		{
			AnimationCancel := "Off"
		} else
		{
			Click
			Sleep, 225
			Click
			Sleep, 225
			SendInput, r
			Sleep, 225
			SendInput, r
			Sleep, 50
		}
	}
} else
{
	AnimationCancel := "Off"
}
Sleep, 250
SetCapsLockState, Off
return

; Amber AutoAttack animation cancelling
AmberAnimationCancelling:
KeyWait, CapsLock, L
AutoAttack := "Off"
AutoRun := "Off"
if (AnimationCancel = "Off")
{
	AnimationCancel := "On"
	Loop,
	{
		if (AnimationCancel = "Off")
		{
			SendInput, w
			break
		} else if !WinActive("ahk_class UnityWndClass")
		{
			AnimationCancel := "Off"
		} else
		{
			Click, Down
			Sleep, 225
			Click, Up
			DllCall("mouse_event", "uInt", 0x01, "uInt", 3, "uInt", y) ; Move the mouse slightly to the right
			Sleep, 225
		}
	}
} else
{
	AnimationCancel := "Off"
}
Sleep, 250
SetCapsLockState, Off
return

; Ningguang AutoAttack animation cancelling
NingguangAnimationCancelling:
KeyWait, CapsLock, L
SendInput, {w Down}
AutoAttack := "Off"
AutoRun := "Off"
if (AnimationCancel = "Off")
{
	AnimationCancel := "On"
	Loop,
	{
		if (AnimationCancel = "Off")
		{
			SendInput, {w Up}
			break
		} else if !WinActive("ahk_class UnityWndClass")
		{
			AnimationCancel := "Off"
		} else
		{
			Click
			Click, WheelDown
			Sleep, 700
			Click
			Click, WheelDown
			Sleep, 300
			Click, Down
			Click, WheelDown
			Sleep, 300
			Click, Up
			Click, WheelDown
			Sleep, 1000
		}
	}
} else
{
	AnimationCancel := "Off"
}
Sleep, 250
SetCapsLockState, Off
return

; 3 attacks to cut wood
Timbersaw:
KeyWait, CapsLock, L
AutoAttack := "Off"
AutoRun := "Off"
Click
Sleep, 500
Click
Sleep, 500
Click
Sleep, 250
SetCapsLockState, Off
return

#IfWinActive

/*
====================================================
Hotkeys
====================================================
*/

~Esc::
if (ElementsGUIStatus = "Open")
{
	ElementsGUIHide()
} else if (SkillTimerConfig = "Open")
{
	SkillTimerConfigHide()
}
return

F12::
Suspend, Toggle
if (A_IsSuspended)
{
	Gui, ScriptSuspendStatus:Add, Text,, Hotkeys Suspended
	Gui, ScriptSuspendStatus:Color, 0xFF0000 ; Red
	Gui, ScriptSuspendStatus:-Caption +Owner -SysMenu +AlwaysOnTop
	Gui, ScriptSuspendStatus:Show, AutoSize x909 y25 NA
} else
{
	Gui, ScriptSuspendStatus:Destroy
}
WinActivate, ahk_class UnityWndClass
return

#IfWinActive ahk_class UnityWndClass

~l::
F3::
AutoRun := "Off"
AutoLoot := "Off"
AutoAttack := "Off"
AnimationCancel := "Off"
SendInput, l
Sleep, 250
return

$MButton::
if (ElementalSight = "Off")
{
	ElementalSight := "On"
	Loop,
	{
		if (ElementalSight = "Off")
		{
			break
		} else if !WinActive("ahk_class UnityWndClass")
		{
			ElementalSight := "Off"
		} else
		{
			SendInput, {MButton down}
			Sleep, 3000
			SendInput, {MButton up}
			Sleep, 250
		}
	}
} else
{
	ElementalSight := "Off"
}
return

~LButton::
~Esc::
~c::
~b::
~m::
~j::
AutoRun := "Off"
AutoAttack := "Off"
AutoLoot := "Off"
AnimationCancel := "Off"
return

~RButton::
AutoAttack := "Off"
AutoLoot := "Off"
AnimationCancel := "Off"
return

~w::
~a::
~s::
~d::
if (AutoRun = "On" AND A_ThisHotkey = "~w")
{
	KeyWait, w, L ; Continue running when AutoRun is enabled but stops when W is released
	AutoRun := "Off"
}
if (A_ThisHotkey = "~s")
{
	AutoRun := "Off"
}
AutoAttack := "Off"
AutoLoot := "Off"
AnimationCancel := "Off"
Click, WheelDown
return

~r::
AutoAttack := "Off"
AnimationCancel := "Off"
return

$1::
SendInput, 1 ; Enables holding 1 to spam 1st character switch
return

$2::
SendInput, 2 ; Enables holding 2 to spam 2nd character switch
return

$3::
SendInput, 3 ; Enables holding 3 to spam 3rd character switch
return

$4::
SendInput, 4 ; Enables holding 4 to spam 4th character switch
return

$Space::
SendInput, {Space} ; Enables holding Space to spam jump
return

~e::
Click, WheelDown ; Zooms out the camera while holding E
return

$q::
SendInput, q ; Enables holding Q to spam Elemental Burst
return

$x::
SendInput, x ; Enables holding X to spam Drop while climbing
return

$t::
SendInput, t ; Enables holding T to spam Interaction button (useful for traversing Thunder Spheres)
return

Tab::
AutoRun := "Off"
AnimationCancel := "Off"
if (AutoAttack = "Off")
{
	AutoAttack := "On"
	Loop,
	{
		if (AutoAttack = "Off")
		{
			break
		} else if !WinActive("ahk_class UnityWndClass")
		{
			AutoAttack := "Off"
		} else
		{
			Click
			Click, WheelDown
		}
	}
} else
{
	AutoAttack := "Off"
}
return

`::
AutoLoot := "Off"
AnimationCancel := "Off"
Gui, AutoLootToggleMessage:Destroy
if (AutoRun = "Off")
{
	AutoRun := "On"
	SendInput, {w down}
	Click, Right, Down
	Sleep, 500
	Click, Right, Up
	Loop,
	{
		if (AutoRun = "Off")
		{
			SendInput, w
			break
		} else if !WinActive("ahk_class UnityWndClass")
		{
			AutoRun := "Off"
		}
		Click, WheelDown
	}
} else
{
	SendInput, {w up}
	AutoRun := "Off"
}
return

g::
AutoAttack := "Off"
if (AutoLoot = "Off")
{
	Gui, AutoLootToggleMessage:Add, Text,, AutoLoot / Dialog fast forward On
	Gui, AutoLootToggleMessage:-Caption +Owner -SysMenu +AlwaysOnTop
	Gui, AutoLootToggleMessage:Show, AutoSize x874 y1030 NA
	AutoLoot := "On"	
	Loop,
	{
		if (AutoLoot = "Off")
		{
			Gui, AutoLootToggleMessage:Destroy
			break
		} else if !WinActive("ahk_class UnityWndClass")
		{
			AutoLoot := "Off"
		} else
		{
			Send, f
			Sleep, 15
			Click, WheelDown
			Sleep, 15
		}
	}
} else
{
	AutoLoot := "Off"
}
return

Home::
Loop, 1000
Click, WheelUp
return

#IfWinActive

/*
====================================================
For debugging purposes; used to monitor the status of the Auto states
====================================================
*/

/*
Gui, Add, Text, vAutoAttackState, AutoAttack State: %AutoAttack%
Gui, Add, Text, vAutoRunState, AutoRun State: %AutoRun%
Gui, Add, Text, vAutoLootState, AutoLoot State: %AutoLoot%
Gui, -SysMenu +AlwaysOnTop
Gui, Show, AutoSize x100 y875, Auto states

SetTimer, AutoStateTimer, 0
return

AutoStateTimer:
GuiControl, Text, AutoAttackState, AutoAttack State: %AutoAttack%
GuiControl, Text, AutoRunState, AutoRun State: %AutoRun%
GuiControl, Text, AutoLootState, AutoLoot State: %AutoLoot%
return
*/