' implementation detail: pipe movement logic is updated manually by drawing only the edges
Sub updatePipes()
    Dim i As Ubyte
    Dim pX As Integer
    Dim gap As Ubyte
    Dim leadingCol As Integer
    Dim trailingCol As Integer
    
    Dim wc As UInteger = worldCol Mod PIPE_PERIOD
    
    If wc = 0 Then
        If pipeActive(0) And pipeX(0) > -PIPE_WIDTH Then
            writePipeColumn(pipeX(0) + PIPE_WIDTH - 1, pipeGap(0), ATTR_SKY)
        End If
        pipeActive(0) = 1
        pipeX(0) = 32
        pipeGap(0) = nextPipeGap(0)
    End If
    If wc = PIPE_SPAWN_INTERVAL Then
        If pipeActive(1) And pipeX(1) > -PIPE_WIDTH Then
            writePipeColumn(pipeX(1) + PIPE_WIDTH - 1, pipeGap(1), ATTR_SKY)
        End If
        pipeActive(1) = 1
        pipeX(1) = 32
        pipeGap(1) = nextPipeGap(1)
    End If
    
    Dim attrFront As Ubyte
    Dim attrBack As Ubyte
    If (worldCol bAnd 1) = 1 Then
        attrFront = ATTR_FIRST_HALF
        attrBack = ATTR_LAST_HALF
    Else
        attrFront = ATTR_PIPE
        attrBack = ATTR_SKY
    End If
    
    ' Pase 1: Dibujar TODAS las partes de ARRIBA primero (para ganar al haz de luz de la TV)
    For i = 0 To 1
        If Not pipeActive(i) Then Continue For
        pX = pipeX(i)
        gap = pipeGap(i)
        leadingCol = pX - 1
        trailingCol = pX + PIPE_WIDTH - 1
        
        If leadingCol >= 0 Then
            If leadingCol <= 31 Then writePipeTop(leadingCol, gap, attrFront)
        End If
        
        If trailingCol >= 0 Then
            If trailingCol <= 31 Then writePipeTop(trailingCol, gap, attrBack)
        End If
    Next i
    
    ' Pase 2: Dibujar TODAS las partes de ABAJO después (el haz ya va más abajo, es seguro)
    For i = 0 To 1
        If Not pipeActive(i) Then Continue For
        pX = pipeX(i)
        gap = pipeGap(i)
        leadingCol = pX - 1
        trailingCol = pX + PIPE_WIDTH - 1
        
        If leadingCol >= 0 Then
            If leadingCol <= 31 Then writePipeBottom(leadingCol, gap, attrFront)
        End If
        
        If trailingCol >= 0 Then
            If trailingCol <= 31 Then writePipeBottom(trailingCol, gap, attrBack)
        End If
        
        If (worldCol bAnd 1) = 0 Then
            pipeX(i) = pX - 1
            If pipeX(i) < -PIPE_WIDTH Then pipeActive(i) = 0
        End If
    Next i
End Sub

Sub scroll()
    waitretrace
    updatePipes()
    paintFloorAttrs()
    worldCol = worldCol + 1
End Sub

Function floorAttr(col As Ubyte) As Ubyte
    Dim phase As Ubyte = worldCol Mod 6
    Return floorAttrPhases(phase, col)
End Function

' ---------------------------------------------------------------
' writePipeColumn col, gap, attr
' Writes attribute bytes for a single column at col (0..31)
' in the play area (rows 0..20) using direct POKE to the
' currently mapped attribute buffer.
' Rows gap..gap+GAP-1  -> ATTR_SKY
' Rows 0..gap-1        -> attr
' Rows gap+GAP..19     -> attr
' Row 20               -> ATTR_FLOOR
' ---------------------------------------------------------------
Sub writePipeTop(col As Ubyte, gap As Ubyte, attr As Ubyte)
    If gap > 0 Then
        paint(col, 1, 1, gap, attr)
    End If
End Sub

Sub writePipeBottom(col As Ubyte, gap As Ubyte, attr As Ubyte)
    Dim pipeLow As Ubyte = 22 - gap - PIPE_GAP_SIZE
    If pipeLow > 0 Then
        paint(col, gap + PIPE_GAP_SIZE + 1, 1, pipeLow, attr)
    End If
End Sub

Sub writePipeColumn(col As Ubyte, gap As Ubyte, attr As Ubyte)
    writePipeTop(col, gap, attr)
    writePipeBottom(col, gap, attr)
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
    ' waitretrace
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