Persistent
TraySetIcon("Main.ico")
A_TrayMenu.Delete
A_TrayMenu.Add("Debug", Debug)
A_TrayMenu.Add("&Reload Script (CTRL + ALT + R)", Reload)
A_TrayMenu.Add("Configure skill timers (F10)", SkillTimerConfig)
A_TrayMenu.Add("Close skill timer indicators", CloseSkillTimer)
A_TrayMenu.Add("E&xit", Exit)

Debug(ItemName, ItemPos, Menu) {
    MsgBox "Hello"
}

Exit(ItemName, ItemPos, Menu) {
    ExitApp
}

Reload(ItemName, ItemPos, Menu) {
    MsgBox "Hello"
}

SkillTimerConfig(ItemName, ItemPos, Menu) {
    MsgBox "Hello"
}