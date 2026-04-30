' Initialise all game variables
Sub initGame(clearScreen As Ubyte)
    Ink 0: Paper 1
    If clearScreen Then
        Cls
    End If
    
    mainCharacterX = MAIN_CHARACTER_INITIAL_X
    mainCharacterY = MAIN_CHARACTER_INITIAL_Y
    mainCharacterOldY = mainCharacterY
    birdVelQ = 8
    birdYAcc = 0
    score = 0
    
    ' World column counter: counts how many columns have entered from the right.
    ' Col 31 shows worldCol mod (PIPE_SPAWN_INTERVAL + PIPE_WIDTH) for each pipe slot.
    worldCol = 0
    pipeGap(0) = 5
    pipeGap(1) = 9
    
    drawHUD()
    initPlayfield()
    drawMainCharacter()
    drawScore()
    drawHiScore()
End Sub

Sub incrementScore()
    score = score + 1
    playScoreFX()
    
    If score > hiScore Then
        hiScore = score
    End If
    
    drawScore()
End Sub

' --- Scoring ---
' pipe0 trailing col (wc=3) painted at worldCol=3, reaches col6 at worldCol=28  -> wc=28%36=28
' pipe1 trailing col (wc=21) painted at worldCol=21, reaches col6 at worldCol=46 -> wc=46%36=10
Sub checkScore()
    ' First pipe is not present for easy play
    If worldCol < 28 Then Return
    
    Dim wc As Ubyte = worldCol Mod PIPE_PERIOD
    
    If wc = 28 Then
        incrementScore()
        pipeGap(0) = 3 + (score Mod 12)
        Return
    End If
    
    If wc = 10 Then
        incrementScore()
        pipeGap(1) = 3 + ((score + 5) Mod 12)
        Return
    End If
End Sub

Sub screenSync()
    waitretrace
    waitretrace
    waitretrace
    waitretrace
End Sub