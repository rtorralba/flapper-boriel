Sub showGameOverScreen()
    Print At 8, 8;  Ink 7; Paper 1; " GAME OVER  "
    Print At 10, 8; Ink 6; Paper 1; " Score: "; score; "  "
    Print At 11, 8; Ink 5; Paper 1; " Best:  "; hiScore; "  "
    Print At 14, 8; Ink 5; Paper 1; " Press SPACE "

    waitForSpace()

    play()
End Sub