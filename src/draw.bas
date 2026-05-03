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
            erasePipeColumn(pipeX(0) + PIPE_WIDTH - 1, pipeGap(0))
        End If
        pipeActive(0) = 1
        pipeX(0) = 32
        pipeGap(0) = nextPipeGap(0)
    End If
    If wc = PIPE_SPAWN_INTERVAL Then
        If pipeActive(1) And pipeX(1) > -PIPE_WIDTH Then
            erasePipeColumn(pipeX(1) + PIPE_WIDTH - 1, pipeGap(1))
        End If
        pipeActive(1) = 1
        pipeX(1) = 32
        pipeGap(1) = nextPipeGap(1)
    End If
    
    For i = 0 To 1
        If pipeActive(i) Then
            pX = pipeX(i)
            gap = pipeGap(i)
            
            leadingCol = pX - 1
            trailingCol = pX + PIPE_WIDTH - 1
            
            If (worldCol Mod 2) = 1 Then
                ' Odd frame: half tiles
                If leadingCol >= 0 And leadingCol <= 31 Then
                    writePipeColumn(leadingCol, gap, ATTR_FIRST_HALF)
                End If
                If trailingCol >= 0 And trailingCol <= 31 Then
                    writePipeColumn(trailingCol, gap, ATTR_LAST_HALF)
                End If
            Else
                ' Even frame: full tiles
                If leadingCol >= 0 And leadingCol <= 31 Then
                    writePipeColumn(leadingCol, gap, ATTR_PIPE)
                End If
                If trailingCol >= 0 And trailingCol <= 31 Then
                    erasePipeColumn(trailingCol, gap)
                End If
                
                pipeX(i) = pX - 1
                
                If pipeX(i) < -PIPE_WIDTH Then
                    pipeActive(i) = 0
                End If
            End If
        End If
    Next i
End Sub

Sub scroll()
    waitretrace
    updatePipes()
    waitretrace
    paintFloorAttrs()
    worldCol = worldCol + 1
    ' drawFloorPixels()
End Sub

Function floorAttr(col As Ubyte) As Ubyte
    Dim worldStep As Ubyte = worldCol / 2
    Dim idx As Ubyte = (col + worldStep) Mod 3
    If (worldCol Mod 2) = 0 Then
        Return attrFloorFullTable(idx)
    Else
        Return attrFloorHalfTable(idx)
    End If
End Function

' ---------------------------------------------------------------
' writePipeColumn col, gap, attr
' Writes attribute bytes for a single column at col (0..31)
' in the play area (rows 0..20) using direct POKE to the
' currently mapped attribute buffer.
' Rows gap..gap+GAP-1  -> ATTR_SKY
' Rows 0..gap-1        -> ATTR_PIPE
' Rows gap+GAP..19     -> ATTR_PIPE
' Row 20               -> ATTR_FLOOR
' ---------------------------------------------------------------
Sub writePipeColumn(col As Ubyte, gap As Ubyte, attr As Ubyte)
    Dim r As Ubyte
    If gap > 0 Then
        For r = 1 To gap
            paint(col, r, 1, 1, attr)
            putChars(col, r, 1, 1, @halfTile(0))
        Next r
    End If
    Dim pipeLow As Ubyte = 22 - gap - PIPE_GAP_SIZE
    If pipeLow > 0 Then
        For r = gap + PIPE_GAP_SIZE + 1 To 22
            paint(col, r, 1, 1, attr)
            putChars(col, r, 1, 1, @halfTile(0))
        Next r
    End If
    paint(col, 23, 1, 1, floorAttr(col))
End Sub

' ---------------------------------------------------------------
' erasePipeColumn col, gap
' Clears the pipe attribute and pixels for the given column,
' leaving the gap untouched.
' ---------------------------------------------------------------
Sub erasePipeColumn(col As Ubyte, gap As Ubyte)
    Dim r As Ubyte
    If gap > 0 Then
        For r = 1 To gap
            putChars(col, r, 1, 1, @emptyTile(0))
            paint(col, r, 1, 1, ATTR_SKY)
        Next r
    End If
    Dim pipeLow As Ubyte = 22 - gap - PIPE_GAP_SIZE
    If pipeLow > 0 Then
        For r = gap + PIPE_GAP_SIZE + 1 To 22
            putChars(col, r, 1, 1, @emptyTile(0))
            paint(col, r, 1, 1, ATTR_SKY)
        Next r
    End If
    paint(col, 23, 1, 1, floorAttr(col))
End Sub

Sub drawFloorPixels()
    Dim c As Ubyte
    For c = 0 To 31
        putChars(c, 23, 1, 1, @halfTile(0))
    Next c
End Sub

Sub paintFloorAttrs()
    Dim c As Ubyte
    Dim worldStep As Ubyte = worldCol / 2
    Dim idx As Ubyte
    For c = 0 To 31
        idx = (c + worldStep) Mod 3
        If (worldCol Mod 2) = 0 Then
            paint(c, 23, 1, 1, attrFloorFullTable(idx))
        Else
            paint(c, 23, 1, 1, attrFloorHalfTable(idx))
        End If
    Next c
End Sub

' ---------------------------------------------------------------
' initPlayfield
' Clears play area pixels and attributes ready for a new game.
' ---------------------------------------------------------------
Sub initPlayfield()
    paint(0, 1, 32, 22, ATTR_SKY)
    drawFloorPixels()
    paintFloorAttrs()
End Sub

' ---------------------------------------------------------------
' Draw the bird sprite at current position with correct attributes
' ---------------------------------------------------------------
Sub drawBird()
    ' Only draw pixels - do NOT overwrite background attributes
    ' so collision detection can read pipe/sky attrs correctly.
    putChars(birdX, Int(birdYPos), 2, 2, @sprite0(0))
End Sub

' ---------------------------------------------------------------
' Erase bird sprite at given position (restore sky attrs + blank pixels)
' ---------------------------------------------------------------
Sub eraseBird(bx As Ubyte, by As Ubyte)
    ' Zero out pixels only - no Print, no paint: attrs stay intact
    putChars(bx, by, 2, 2, @blankSprite(0))
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