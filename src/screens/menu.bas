Sub showMenuScreen()
    Print At 8,  9; Ink 7; Paper 1; " BORIEL FLAPPER  "
    Print At 10, 0; Ink 6; Paper 1; " Based on ZX Moe Flapper Type-in "
    Print At 14, 9; Ink 6; Paper 1; Flash 1; " Press SPACE "

    waitForSpace()

    showPlayGameScreen()
End Sub