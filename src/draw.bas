' Draw the bird sprite at current position with correct attributes
Sub drawMainCharacter()
    putChars(mainCharacterX, mainCharacterY, 2, 2, @sprite0(0))
    paintData(mainCharacterX, mainCharacterY, 2, 2, @birdAttr(0))
End Sub

' Draw a full pipe column spanning the play area (rows 0-20)
Sub drawPipe(col As Ubyte, gap As Ubyte)
    Dim r As Ubyte
    For r = 0 To gap - 1
        Print At r, col; INK 7; Paper 4; "    "
    Next r
    For r = gap To gap + PIPE_GAP_SIZE - 1
        Print At r, col; INK 7; Paper 1; "    "
    Next r
    For r = gap + PIPE_GAP_SIZE To 20
        Print At r, col; INK 7; Paper 4; "    "
    Next r
End Sub

' Draw a single 1-cell-wide column of the pipe pattern
Sub drawPipeColumn(col As Ubyte, gap As Ubyte)
    Dim r As Ubyte
    For r = 0 To gap - 1
        Print At r, col; INK 7; Paper 4; " "
    Next r
    For r = gap To gap + PIPE_GAP_SIZE - 1
        Print At r, col; INK 7; Paper 1; " "
    Next r
    For r = gap + PIPE_GAP_SIZE To 20
        Print At r, col; INK 7; Paper 4; " "
    Next r
End Sub

' Erase a single screen column with background colour (play area only)
Sub eraseColumn(col As Ubyte)
    Dim r As Ubyte
    For r = 0 To 20
        Print At r, col; INK 1; Paper 1; " "
    Next r
End Sub

' Draw the HUD bar (rows 21-23) - called once, never overwritten by game
Sub drawHUD()
    Dim c As Ubyte
    ' Separator line
    For c = 0 To 31
        Print At 21, c; INK 6; Paper 6; " "
    Next c
    ' Score label
    Print At 22, 1; INK 7; Paper 0; "SCORE:"
    Print At 22, 10; INK 7; Paper 0; "FLAPPY ZX"
End Sub

' Update score display in HUD
Sub drawScore()
    Print At 22, 7; INK 6; Paper 0; score; "   "
End Sub

' Show game over message
Sub drawGameOver()
    Print At 8, 8;  INK 7; Paper 0; "  GAME OVER  "
    Print At 10, 8; INK 6; Paper 0; "  Score: "; score; "  "
    Print At 12, 9; INK 5; Paper 0; " Press SPACE "
End Sub

' Show start screen
Sub drawStartScreen()
    Print At 8,  9; INK 7; Paper 0; " FLAPPY ZX  "
    Print At 10, 9; INK 6; Paper 0; " Press SPACE "
End Sub