Sub showMenuScreen()
    Print At 4,  7; Paper 0; Ink 0;             "                "
    Print At 5,  7; Paper 0; Ink 7;             " BORIEL FLAPPER "
    Print At 6,  7; Paper 0; Ink 0;             "                "
    Print At 7,  7; Paper 0; Ink 6;             "    based on    "
    Print At 8,  7; Paper 0; Ink 6;             " ZX Moe Flapper "
    Print At 9,  7; Paper 0; Ink 0;             "                "
    Print At 10, 7; Paper 0; Ink 7;             " (C) Juntelart  "
    Print At 11, 7; Paper 0; Ink 0;             "                "
    Print At 12, 7; Paper 0; Ink 0;             "                "
    Print At 13, 7; Paper 0; Ink 5; Flash 1;    "  Press SPACE   "
    Print At 14, 7; Paper 0; Ink 0; Flash 0;    "                "

    putChars(8, 18, 2, 2, @sprite0(0))
    putChars(14, 16, 2, 2, @sprite0(0))
    putChars(20, 18, 2, 2, @sprite0(0))

    waitForSpace()

    showPlayGameScreen()
End Sub