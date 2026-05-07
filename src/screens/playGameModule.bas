' Initialise all game variables
Sub initGame(clearScreen As Ubyte)
    Ink 0: Paper 1
    If clearScreen Then
        Cls
    End If
    
    birdX    = BIRD_INITIAL_X
    birdOldY = BIRD_INITIAL_Y
    birdVel  = BIRD_INITIAL_VEL
    birdYPos = BIRD_INITIAL_Y
    score = 0
    
    ' World column counter: counts how many columns have entered from the right.
    ' Col 31 shows worldCol mod (PIPE_SPAWN_INTERVAL + PIPE_WIDTH) for each pipe slot.
    worldCol = 0
    pipeActive(0) = 0
    pipeActive(1) = 0
    pipeX(0) = 32
    pipeX(1) = 32
    pipeGap(0) = 5
    pipeGap(1) = 9
    nextPipeGap(0) = 5
    nextPipeGap(1) = 9
    
    initPlayfield()
    drawHUD()
    drawBird()
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
    If pipeActive(0) And pipeX(0) = birdX And (worldCol bAnd 1) = 0 Then
        incrementScore()
        nextPipeGap(0) = 3 + (score Mod 12)
    End If
    
    If pipeActive(1) And pipeX(1) = birdX And (worldCol bAnd 1) = 0 Then
        incrementScore()
        nextPipeGap(1) = 3 + ((score + 5) Mod 12)
    End If
End Sub

Sub screenSync()
    If score < 10 Then
        ' At low score, run at half speed to give player more time to react
        waitretrace
    End If
End Sub