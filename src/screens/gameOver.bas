Sub showGameOverScreen()
    Print At 7,  7; Paper 0; Ink 0;             "                "
    Print At 8,  7; Paper 0; Ink 7;             "   GAME OVER!   "
    Print At 9,  7; Paper 0; Ink 0;             "                "
    Print At 10, 7; Paper 0; Ink 6;             "  Score:   "; zeroPad3(score); "  "
    Print At 11, 7; Paper 0; Ink 5;             "  Best:    "; zeroPad3(hiScore); "  "
    Print At 12, 7; Paper 0; Ink 0;             "                "
    Print At 13, 7; Paper 0; Ink 5; Flash 1;    " Press  ANY KEY "
    Print At 14, 7; Paper 0; Ink 0; Flash 0;    "                "

    waitAnyKey()

    showPlayGameScreen(1)
End Sub