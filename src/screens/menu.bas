Sub showMenuScreen()
    initPlayfield()

    Print At 4,  7; Paper 0; Ink 0;             "                "
    Print At 5,  7; Paper 0; Ink 7;             " FLAPPER BORIEL "
    Print At 6,  7; Paper 0; Ink 0;             "                "
    Print At 7,  7; Paper 0; Ink 6;             "    based on    "
    Print At 8,  7; Paper 0; Ink 6;             " ZX Moe Flapper "
    Print At 9,  7; Paper 0; Ink 0;             "                "
    Print At 10, 7; Paper 0; Ink 7;             " (C) Juntelart  "
    Print At 11, 7; Paper 0; Ink 0;             "                "
    Print At 12, 7; Paper 0; Ink 0;             "                "
    Print At 13, 7; Paper 0; Ink 5; Flash 1;    " Press  ANY KEY "
    Print At 14, 7; Paper 0; Ink 0; Flash 0;    "                "

    birdX    = BIRD_INITIAL_X
    birdYPos = BIRD_INITIAL_Y
    drawBird()

    waitAnyKey()

    ' Clear menu box area (cols 7..22, rows 4..14)
    clearBox(7, 4, 16, 10)
    paint(7, 4, 16, 10, ATTR_SKY)

    showPlayGameScreen(0)
End Sub