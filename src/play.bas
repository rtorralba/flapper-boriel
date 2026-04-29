' ---------------------------------------------------------------
' World scroll counter: tracks how many columns have scrolled in
' for the rightmost pipe, so we know what to paint in col 31.
' pipeScrollCol(i): which column of pipe i is currently entering
'                   from the right.  0 = first col of pipe body,
'                   PIPE_WIDTH = gap between pipes,
'                   >PIPE_WIDTH+PIPE_SPAWN_INTERVAL = sky
' We drive this with a single world counter worldCol.
' ---------------------------------------------------------------

' Initialise all game variables
Sub initGame()
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

    Ink 0
    Paper 1
    Cls
    initPlayfield()
    drawHUD()
    drawMainCharacter()
    drawScore()
    drawHiScore()
End Sub

' ---------------------------------------------------------------
' Determine what to draw in column 31 given current worldCol.
' Each pipe slot covers PIPE_WIDTH + PIPE_SPAWN_INTERVAL columns.
' Within that window: cols 0..PIPE_WIDTH-1 are pipe, rest is sky.
' Two pipes are interleaved: pipe0 starts at worldCol=0 phase,
' pipe1 is offset by PIPE_SPAWN_INTERVAL columns.
' ---------------------------------------------------------------
Sub paintRightColumn()
    ' period = 2 * PIPE_SPAWN_INTERVAL = 36
    ' wc 0..3         -> pipe0  (4 cols)
    ' wc 4..17        -> sky    (14 cols)
    ' wc 18..21       -> pipe1  (4 cols)
    ' wc 22..35       -> sky    (14 cols)
    Dim period As Ubyte = 2 * PIPE_SPAWN_INTERVAL
    Dim wc As Ubyte = worldCol Mod period
    If wc < PIPE_WIDTH Then
        writeAttrColumn(31, pipeGap(0))
    ElseIf wc >= PIPE_SPAWN_INTERVAL And wc < PIPE_SPAWN_INTERVAL + PIPE_WIDTH Then
        writeAttrColumn(31, pipeGap(1))
    Else
        writeSkyColumn(31)
    End If
End Sub

' ---------------------------------------------------------------
' Check collision: bird overlaps a pipe attr (ATTR_PIPE = 0x20)
' Read directly from attr buffer for speed.
' ---------------------------------------------------------------
Function checkBirdCollision(bx As Ubyte, by As Ubyte) As Ubyte
    Dim attrBuf(0) As Ubyte
    ' Check all 4 cells of the 2x2 bird for ATTR_PIPE
    getPaintData(bx,     by,     1, 1, @attrBuf(0))
    If attrBuf(0) = ATTR_PIPE Then Return 1
    getPaintData(bx + 1, by,     1, 1, @attrBuf(0))
    If attrBuf(0) = ATTR_PIPE Then Return 1
    getPaintData(bx,     by + 1, 1, 1, @attrBuf(0))
    If attrBuf(0) = ATTR_PIPE Then Return 1
    getPaintData(bx + 1, by + 1, 1, 1, @attrBuf(0))
    If attrBuf(0) = ATTR_PIPE Then Return 1
    Return 0
End Function

Sub play()
    Dim period As Ubyte

    Do  ' outer restart loop

        Do
        Loop Until isSpacePressed()
        Do
        Loop While isSpacePressed()

        initGame()
        period = 2 * PIPE_SPAWN_INTERVAL  ' = 36

        ' Main game loop
        Do
            ' --- Wait 2 VBLs per game tick -> 25fps logic (same as original with double-buffer) ---
            waitretrace
            waitretrace
            waitretrace
            waitretrace

            readKeyboard()

            gravity()

            ' --- Scoring ---
            ' pipe0 trailing col (wc=3) painted at worldCol=3, reaches col6 at worldCol=28  -> wc=28%36=28
            ' pipe1 trailing col (wc=21) painted at worldCol=21, reaches col6 at worldCol=46 -> wc=46%36=10
            Dim wc As Ubyte = worldCol Mod period
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

            ' --- Scroll + paint (worldCol increment is AFTER so scoring and paint use same value) ---
            scrollPlayfieldAttrs()
            paintRightColumn()
            worldCol = worldCol + 1

            ' --- Collision check (attrs are background only, bird pixels don't affect them) ---
            If checkBirdCollision(mainCharacterX, mainCharacterY) Then
                gameOver = 1
            End If

            ' --- Erase bird at old position (pixels only) ---
            eraseBird(mainCharacterX, mainCharacterOldY)

            ' --- Draw bird (pixels only) ---
            drawMainCharacter()

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
