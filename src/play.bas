' Returns 1 if SPACE key (key code 32) is pressed
Function isSpacePressed() As Ubyte
    If Inkey$ = " " Then
        Return 1
    End If
    Return 0
End Function

' Initialise all game variables
Sub initGame()
    mainCharacterX = 6
    mainCharacterY = 10
    mainCharacterOldX = mainCharacterX
    mainCharacterOldY = mainCharacterY
    birdVelQ = 8    ' start at terminal velocity so fall is immediate
    birdYAcc = 0
    score = 0
    gameOver = 0

    pipeX(0) = 28
    pipeGap(0) = 5
    pipeX(1) = 28 + PIPE_SPAWN_INTERVAL
    pipeGap(1) = 9

    activateShadowScreen()

    ' Draw full initial state into both buffers
    Dim b As Ubyte
    For b = 0 To 1
        switchBankToDrawHidden()
        Paper 1
        Cls
        drawHUD()
        drawPipe(pipeX(0), pipeGap(0))
        drawMainCharacter()
        drawScore()
        toggleScreen()
    Next b

    ' Init shadow positions for both buffers
    shadowBirdX(0) = mainCharacterX
    shadowBirdX(1) = mainCharacterX
    shadowBirdY(0) = mainCharacterY
    shadowBirdY(1) = mainCharacterY
    shadowPipeX0(0) = pipeX(0)
    shadowPipeX0(1) = pipeX(0)
    shadowPipeX1(0) = pipeX(1)
    shadowPipeX1(1) = pipeX(1)
End Sub

' Check collision: bird (2x2 at bx,by) vs pipe at px with gap pg
Function birdHitsPipe(bx As Ubyte, by As Ubyte, px As Ubyte, pg As Ubyte) As Ubyte
    ' Horizontal overlap: bird cols bx..bx+1, pipe cols px..px+1
    If bx + 1 < px Then Return 0
    If bx > px + PIPE_WIDTH - 1 Then Return 0
    ' Vertical overlap with solid parts
    ' Top pipe: rows 0..pg-1, bottom pipe: rows pg+PIPE_GAP_SIZE..22
    If by < pg Then Return 1        ' bird top overlaps top pipe
    If by + 1 >= pg + PIPE_GAP_SIZE Then Return 1  ' bird bottom overlaps bottom pipe
    Return 0
End Function

Sub play()
    Dim i As Ubyte
    Dim bufIdx As Ubyte
    Dim oldX As Ubyte
    Dim er As Ubyte
    Dim trailA As Ubyte
    Dim trailB As Ubyte

    Do  ' outer restart loop

        Do
        Loop Until isSpacePressed()
        Do
        Loop While isSpacePressed()

        initGame()

        ' Main game loop
        Do
            ' --- Input ---
            If isSpacePressed() Then
                birdVelQ = -8
                birdYAcc = 0
            End If

            ' --- Physics (accumulator eliminates dead zone) ---
            birdVelQ = birdVelQ + 2
            If birdVelQ > 10 Then birdVelQ = 10

            mainCharacterOldX = mainCharacterX
            mainCharacterOldY = mainCharacterY

            Dim newY As Integer
            birdYAcc = birdYAcc + birdVelQ
            Dim dy As Integer = birdYAcc / 4
            birdYAcc = birdYAcc - dy * 4
            newY = mainCharacterY + dy
            If newY < 0 Then newY = 0
            If newY > 19 Then
                gameOver = 1
            End If
            mainCharacterY = newY

            ' --- Pipe movement, scoring, collision ---
            For i = 0 To 1
                If pipeX(i) = 0 Then
                    pipeX(i) = 32
                    pipeGap(i) = 3 + ((score + i * 5) Mod 12)
                Else
                    pipeX(i) = pipeX(i) - 1
                End If
                If pipeX(i) + PIPE_WIDTH = mainCharacterX Then
                    score = score + 1
                End If
                If pipeX(i) <= 30 Then
                    If birdHitsPipe(mainCharacterX, mainCharacterY, pipeX(i), pipeGap(i)) Then
                        gameOver = 1
                    End If
                End If
            Next i

            ' --- Determine which buffer we are about to draw to ---
            ' bufIdx 0 = bank 5, bufIdx 1 = bank 7
            If currentVisibleScreen = 5 Then
                bufIdx = 1
            Else
                bufIdx = 0
            End If

            switchBankToDrawHidden()

            ' --- Erase bird at its shadow position for this buffer ---
            For er = 0 To 1
                Print At shadowBirdY(bufIdx) + er, shadowBirdX(bufIdx); INK 1; Paper 1; "  "
            Next er

            ' --- Incremental pipe update (erase 2 trailing, draw 2 leading) ---
            For i = 0 To 1
                If i = 0 Then
                    oldX = shadowPipeX0(bufIdx)
                Else
                    oldX = shadowPipeX1(bufIdx)
                End If

                If pipeX(i) > oldX Then
                    ' Pipe teleported (respawned): erase all 4 old columns
                    If oldX <= 31 Then eraseColumn(oldX)
                    If oldX + 1 <= 31 Then eraseColumn(oldX + 1)
                    If oldX + 2 <= 31 Then eraseColumn(oldX + 2)
                    If oldX + 3 <= 31 Then eraseColumn(oldX + 3)
                Else
                    ' Normal: erase 2 trailing columns
                    trailA = pipeX(i) + PIPE_WIDTH
                    trailB = pipeX(i) + PIPE_WIDTH + 1
                    If trailA <= 31 Then eraseColumn(trailA)
                    If trailB <= 31 Then eraseColumn(trailB)
                    ' Draw 2 new leading columns
                    If pipeX(i) <= 31 Then drawPipeColumn(pipeX(i), pipeGap(i))
                    If pipeX(i) + 1 <= 31 Then drawPipeColumn(pipeX(i) + 1, pipeGap(i))
                End If

                If i = 0 Then
                    shadowPipeX0(bufIdx) = pipeX(i)
                Else
                    shadowPipeX1(bufIdx) = pipeX(i)
                End If
            Next i

            ' --- Draw bird and save shadow position ---
            drawMainCharacter()
            shadowBirdX(bufIdx) = mainCharacterX
            shadowBirdY(bufIdx) = mainCharacterY

            drawScore()
            toggleScreen()

        Loop Until gameOver

        ' Game over screen into hidden buffer then flip
        switchBankToDrawHidden()
        drawGameOver()
        toggleScreen()

        Do
        Loop While isSpacePressed()

    Loop  ' restart

End Sub
