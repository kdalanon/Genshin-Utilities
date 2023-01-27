#SingleInstance Force
#NoTrayIcon

IniRead, SavedCharacterSlot3, Character Skill Timer Scripts\Config.ini, Characters, SavedCharacterSlot3
IniRead, SlowingWater, Character Skill Timer Scripts\Config.ini, Options, %SlowingWater%

/*
====================================================
Character cooldown list in seconds
====================================================
*/

Xiangling := 12
Ningguang := 12
Amber := 15
Kaeya := 6
AetherAnemo := 8
AetherGeo := 6
AetherElectro := 14
Fischl := 25
Lisa := 16
Barbara := 26
Diona := 15
Beidou := 8

/*
====================================================
Initialize third party member as not the current
active character
====================================================
*/

CurrentCharacter := "Inactive"

/*
====================================================
GUI and subroutine for skill timer indicator
====================================================
*/

SkillTimerGUI := "Show"
HiddenByPlayer := "No"

Gui, Add, Text, vSkillTimer, Ready
Gui, Color, 0x00FF00 ; Lime
Gui, -Caption +Owner -SysMenu +AlwaysOnTop
if WinActive("ahk_class UnityWndClass")
{
	Gui, Show, AutoSize NA x1525 y445,,
}
return

Start:
GuiControl, Text, SkillTimer, %SkillTimer%
Switch
{
	Case SkillTimer = 0:
		GuiControl, Text, SkillTimer, Ready
		Gui, Color, 0x00FF00 ; Lime
		SkillTimer := %SavedCharacterSlot3%
		SetTimer, Start, Off
	Case SkillTimer > 5:
		Gui, Color, 0xFF0000 ; Red
		SkillTimer--
	Case SkillTimer <= 5:
		Gui, Color, 0xFFFF00 ; Yellow
		SkillTimer--
}
Sleep, 1000
return

OnWinActiveChange(hWinEventHook, vEvent, hWnd)
{
	Global
	static _ := DllCall("user32\SetWinEventHook", UInt,0x3, UInt,0x3, Ptr,0, Ptr,RegisterCallback("OnWinActiveChange"), UInt,0, UInt,0, UInt,0, Ptr)
	DetectHiddenWindows, On
	WinGetClass, WinClass, % "ahk_id " hWnd
	if (WinClass = "UnityWndClass" AND HiddenByPlayer = "No")
	{
		Gui, Show, AutoSize NA x1525 y445,,
		SkillTimerGUI := "Show"
	} else
	{
		Gui, Hide
		SkillTimerGUI := "Hide"
	}
}

/*
====================================================
Hotkeys to be activated ingame
====================================================
*/

#IfWinActive ahk_class UnityWndClass

~3::
CurrentCharacter := "Active"
return

~1::
~2::
~4::
CurrentCharacter := "Inactive"
return

~e up::
if (CurrentCharacter = "Active")
{
	if (SavedCharacterSlot3 != "")
	{
		Switch SlowingWater
		{
			Case "SlowingWater=1": SkillTimer := Format("{:d}", (%SavedCharacterSlot3% / 100) * 250)
			Case "SlowingWater=0": SkillTimer := %SavedCharacterSlot3%
		}
		
		SetTimer, Start, 0
	}
}
return

~F11::
Switch SkillTimerGUI
{
	Case "Hide":
		Gui, Show, NA
		SkillTimerGUI := "Show"
		HiddenByPlayer := "No"
	Case "Show":
		Gui, Hide
		SkillTimerGUI := "Hide"
		HiddenByPlayer := "Yes"
}
return

#IfWinActive