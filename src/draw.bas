' Writes a full play-area column (rows 1..22) into screenBuffer.
' Top rows 1..gap and bottom rows gap+PIPE_GAP_SIZE+1..22 get attr.
' Gap rows get ATTR_SKY. Passing attr=ATTR_SKY erases the whole column.
' NOTE: index = (r-1)*32+col can exceed 255 so we use a UInteger offset
'       that starts at col (row 1) and advances 32 per row to avoid overflow.
Sub bufferPipeColumn(col As Ubyte, gap As Ubyte, attr As Ubyte)
    Dim r As Ubyte
    Dim offset As UInteger = col  ' offset for row 1, col col  (=(1-1)*32+col)
    For r = 1 To gap
        screenBuffer(offset) = attr
        offset = offset + 32
    Next r
    For r = gap + 1 To gap + PIPE_GAP_SIZE
        screenBuffer(offset) = ATTR_SKY
        offset = offset + 32
    Next r
    For r = gap + PIPE_GAP_SIZE + 1 To 22
        screenBuffer(offset) = attr
        offset = offset + 32
    Next r
End Sub

' Computes all pipe state and writes attribute columns directly into screenBuffer.
' No screen memory is touched here. Call before waitretrace.
Sub bufferPipes()
    Dim i As Ubyte
    Dim pX As Integer
    Dim gap As Ubyte
    Dim leadingCol As Integer
    Dim trailingCol As Integer
    
    Dim wc As UInteger = worldCol Mod PIPE_PERIOD
    
    If wc = 0 Then
        If pipeActive(0) And pipeX(0) > -PIPE_WIDTH Then
            bufferPipeColumn(pipeX(0) + PIPE_WIDTH - 1, pipeGap(0), ATTR_SKY)
        End If
        pipeActive(0) = 1
        pipeX(0) = 32
        pipeGap(0) = nextPipeGap(0)
    End If
    If wc = PIPE_SPAWN_INTERVAL Then
        If pipeActive(1) And pipeX(1) > -PIPE_WIDTH Then
            bufferPipeColumn(pipeX(1) + PIPE_WIDTH - 1, pipeGap(1), ATTR_SKY)
        End If
        pipeActive(1) = 1
        pipeX(1) = 32
        pipeGap(1) = nextPipeGap(1)
    End If
    
    Dim attrFront As Ubyte
    Dim attrBack As Ubyte
    If worldCol Mod 2 = 1 Then
        attrFront = ATTR_FIRST_HALF
        attrBack = ATTR_LAST_HALF
    Else
        attrFront = ATTR_PIPE
        attrBack = ATTR_SKY
    End If
    
    For i = 0 To 1
        If Not pipeActive(i) Then Continue For
        pX = pipeX(i)
        gap = pipeGap(i)
        leadingCol = pX - 1
        trailingCol = pX + PIPE_WIDTH - 1
        
        If leadingCol >= 0 And leadingCol <= 31 Then
            bufferPipeColumn(leadingCol, gap, attrFront)
        End If
        
        If trailingCol >= 0 And trailingCol <= 31 Then
            bufferPipeColumn(trailingCol, gap, attrBack)
        End If
        
        If worldCol Mod 2 = 0 Then
            pipeX(i) = pX - 1
            If pipeX(i) < -PIPE_WIDTH Then pipeActive(i) = 0
        End If
    Next i
End Sub

Sub bufferFloor()
    Dim phase As Ubyte = worldCol Mod 6
    memcopy(@floorAttrPhases(phase, 0), @screenBuffer(704), 32)
End Sub

' Copies the floor phase into screenBuffer row 23, then blits the entire
' attribute buffer (rows 1..23, 736 bytes) to screen in one memcopy.
' Call immediately after waitretrace.
Sub renderBufferToScreen()
    memcopy(@screenBuffer(0), 22560, 736)
End Sub

Sub scroll()
    bufferPipes()
    bufferFloor()
    waitretrace
    renderBufferToScreen()
    redrawBird()
    worldCol = worldCol + 1
End Sub

Sub drawPlayfieldPixels()
    Dim r As Ubyte
    Dim c As Ubyte
    For r = 1 To 23
        For c = 0 To 31
            putChars(c, r, 1, 1, @halfTile(0))
        Next c
    Next r
End Sub

Sub paintFloorAttrs()
    Dim phase As Ubyte = worldCol Mod 6
    ' Copy 32 bytes from the 2D matrix directly to row 23 attributes
    memcopy(@floorAttrPhases(phase, 0), 23264, 32)
End Sub

' ---------------------------------------------------------------
' initPlayfield
' Clears play area pixels and attributes ready for a new game.
' ---------------------------------------------------------------
Sub initPlayfield()
    paint(0, 1, 32, 22, ATTR_SKY)
    drawPlayfieldPixels()
    paintFloorAttrs()
    ' Also initialise screenBuffer so bufferPipes starts from a clean state
    Dim j As UInteger
    For j = 0 To 703
        screenBuffer(j) = ATTR_SKY
    Next j
End Sub

' ---------------------------------------------------------------
' Draw the bird sprite at current position with correct attributes
' ---------------------------------------------------------------
Sub drawBird()
    ' Calculate yo-yo animation frame (0, 1, 2, 1) changing every 2 ticks
    Dim animIdx As Ubyte = (worldCol / 2) Mod 4
    If animIdx = 3 Then animIdx = 1
    
    ' Draw pixels based on animation frame
    If animIdx = 0 Then
        putChars(birdX, Int(birdYPos), 2, 2, @sprite0(0))
    ElseIf animIdx = 1 Then
        putChars(birdX, Int(birdYPos), 2, 2, @sprite1(0))
    Else
        putChars(birdX, Int(birdYPos), 2, 2, @sprite2(0))
    End If
    
    ' Paint bird with Yellow Ink (6) and Blue Paper (1) -> 14
    paint(birdX, Int(birdYPos), 2, 2, 14)
End Sub

' ---------------------------------------------------------------
' Erase bird sprite at given position (restore sky attrs + blank pixels)
' ---------------------------------------------------------------
Sub eraseBird(bx As Ubyte, by As Ubyte)
    ' Restore halfTile pattern instead of leaving a blank hole
    putChars(bx, by, 1, 1, @halfTile(0))
    putChars(bx + 1, by, 1, 1, @halfTile(0))
    putChars(bx, by + 1, 1, 1, @halfTile(0))
    putChars(bx + 1, by + 1, 1, 1, @halfTile(0))
    
    ' Restore the sky attributes in one line
    paint(bx, by, 2, 2, ATTR_SKY)
End Sub

Sub redrawBird()
    eraseBird(birdX, birdOldY)
    drawBird()
End Sub

' ---------------------------------------------------------------
' Draw the HUD bar (row 0) - called once at startup
' ---------------------------------------------------------------
Sub drawHUD()
    paint(0, 0, 32, 1, 7)  ' Paper 0 (black), Ink 7 (white) for full row
    Print At 0, 0; Ink 7; Paper 0; "SCORE:"
    Print At 0, 10; Ink 7; Paper 0; "HI:"
    Print At 0, 18; Ink 7; Paper 0; "FLAPPER BORIEL"
    
    drawScore()
    drawHiScore()
End Sub

' Update score display in HUD
Sub drawScore()
    Print At 0, 6; Ink 6; Paper 0; zeroPad3(score);
End Sub

' Update hi-score display in HUD
Sub drawHiScore()
    Print At 0, 13; Ink 5; Paper 0; zeroPad3(hiScore);
End Sub