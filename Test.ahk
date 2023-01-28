#SingleInstance
Persistent
TraySetIcon("Main.ico")
A_TrayMenu.Delete

; Create the last menu first, '<CharacterName>AnimationCancellingTrayToggle' is the label to be executed when you click the item
NormalAttackAnimationCancellingOn := Menu()
NormalAttackAnimationCancellingOn.Add("Barbara", BarbaraAnimationCancellingTrayToggle, "+Radio")
NormalAttackAnimationCancellingOn.Add("Kaeya", KaeyaAnimationCancellingTrayToggle, "+Radio")
NormalAttackAnimationCancellingOn.Add("Fischl", FischlAnimationCancellingTrayToggle, "+Radio")
NormalAttackAnimationCancellingOn.Add("Amber", AmberAnimationCancellingTrayToggle, "+Radio")
NormalAttackAnimationCancellingOn.Add("Ningguang", NingguangAnimationCancellingTrayToggle, "+Radio")
NormalAttackAnimationCancellingOn.Add("Timbersaw", TimbersawAnimationCancellingTrayToggle, "+Radio")

; Then attach it to the second menu as you create it
NormalAttackAnimationCancellingToggle := Menu()
NormalAttackAnimationCancellingToggle.Add("On", NormalAttackAnimationCancellingOn, "+Radio")
NormalAttackAnimationCancellingToggle.Add("Off", NormalAttackAnimationCancellingToggleOff, "+Radio")
NormalAttackAnimationCancellingToggle.Check("Off")

; Finally, create the first menu
A_TrayMenu.Add("Normal Attack Animation Cancel", NormalAttackAnimationCancellingToggle)
A_TrayMenu.Add("E&xit", Exit)

NormalAttackAnimationCancellingToggleOn(*) {
    MsgBox "On"
}

NormalAttackAnimationCancellingToggleOff(*) {
    MsgBox "Off"
}

BarbaraAnimationCancellingTrayToggle(*) {
    NormalAttackAnimationCancellingOn.Check("Barbara")
}

KaeyaAnimationCancellingTrayToggle(*) {
    MsgBox "Kaeya"
}

FischlAnimationCancellingTrayToggle(*) {
    MsgBox "Fischl"
}

AmberAnimationCancellingTrayToggle(*) {
    MsgBox "Amber"
}

NingguangAnimationCancellingTrayToggle(*) {
    MsgBox "Ningguang"
}

TimbersawAnimationCancellingTrayToggle(*) {
    MsgBox "Timbersaw"
}

Exit(*) {
    ExitApp
}