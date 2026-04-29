' Initialise all game variables
Sub initGame()
    Ink 0: Paper 1: Cls

    mainCharacterX = 6
    mainCharacterY = 10
    mainCharacterOldY = mainCharacterY
    birdVelQ = 8
    birdYAcc = 0
    score = 0
    gameOver = 0
    
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

Sub checkScore()
    ' --- Scoring ---
    ' pipe0 trailing col (wc=3) painted at worldCol=3, reaches col6 at worldCol=28  -> wc=28%36=28
    ' pipe1 trailing col (wc=21) painted at worldCol=21, reaches col6 at worldCol=46 -> wc=46%36=10
    Dim wc As Ubyte = worldCol Mod PIPE_PERIOD
    If wc = 28 And worldCol >= 28 Then
        score = score + 1
        playScoreFX()
        pipeGap(0) = 3 + (score Mod 12)
    End If
    If wc = 10 And worldCol >= 46 Then
        score = score + 1
        playScoreFX()
        pipeGap(1) = 3 + ((score + 5) Mod 12)
    End If
End Sub

Sub play()
    Do  ' outer restart loop
        
        Do
        Loop Until isSpacePressed()
        Do
        Loop While isSpacePressed()
        
        initGame()
        
        ' Main game loop
        Do
            ' --- Wait 2 VBLs per game tick -> 25fps logic (same as original with double-buffer) ---
            waitretrace
            waitretrace
            waitretrace
            waitretrace
            
            readKeyboard()
            
            gravity()
            
            scroll()
            
            checkCollision()
            
            redrawMainCharacter()
            
            checkScore()
            drawScore()
        Loop Until gameOver
        
        If score > hiScore Then
            hiScore = score
        End If
        
        ' Game over screen
        drawGameOver()
        
        Do
        Loop While isSpacePressed()
        
    Loop  ' restart
    
End Sub
