' If move all attibutes at the same time, it produces a flickering at last column and the bird
' MemMove($5821, $5820, 23 * 32 - 1)
Sub scrollPlayfieldAttrs()
    Dim row As Ubyte
    Dim src As UInteger = $5821
    Dim dst As UInteger = $5820
    For row = 0 To 23
        MemMove(src, dst, 31)
        src = src + 32
        dst = dst + 32
    Next row
End Sub

' ---------------------------------------------------------------
' Determine what to draw in column 31 given current worldCol.
' Each pipe slot covers PIPE_WIDTH + PIPE_SPAWN_INTERVAL columns.
' Within that window: cols 0..PIPE_WIDTH-1 are pipe, rest is sky.
' Two pipes are interleaved: pipe0 starts at worldCol=0 phase,
' pipe1 is offset by PIPE_SPAWN_INTERVAL columns.
' ---------------------------------------------------------------
Sub paintLastColumn()
    ' period = 2 * PIPE_SPAWN_INTERVAL = 36
    ' wc 0..3         -> pipe0  (4 cols)
    ' wc 4..17        -> sky    (14 cols)
    ' wc 18..21       -> pipe1  (4 cols)
    ' wc 22..35       -> sky    (14 cols)

    Dim wc As Ubyte = worldCol Mod PIPE_PERIOD
    Dim attribute As Ubyte = ATTR_PIPE
    Dim pipeLastCol As Ubyte = PIPE_WIDTH - 1

    If wc < PIPE_WIDTH Then
        If wc = pipeLastCol Then
            attribute = ATTR_PIPE_SHADOW
        End If

        writePipeColumn(31, pipeGap(0), attribute)

        Return
    End If

    If wc >= PIPE_SPAWN_INTERVAL Then
        If wc < PIPE_SPAWN_INTERVAL + PIPE_WIDTH Then
            If wc - PIPE_SPAWN_INTERVAL = pipeLastCol Then
                attribute = ATTR_PIPE_SHADOW
            End If

            writePipeColumn(31, pipeGap(1), attribute)
            
            Return
        End If
    End If
    
    
    writeSkyColumn(31)
End Sub

Sub scroll()
    ' --- Scroll + paint (worldCol increment is AFTER so scoring and paint use same value) ---
    scrollPlayfieldAttrs()
    paintLastColumn()
    worldCol = worldCol + 1
End Sub

Function floorAttr() As Ubyte
    Dim t As Ubyte = worldCol Mod 3
    If t = 0 Then Return ATTR_FLOOR
    If t = 1 Then Return ATTR_FLOOR_BRIGHT
    Return ATTR_FLOOR_MAG
End Function

' ---------------------------------------------------------------
' writePipeColumn col, gap, attr
' Writes attribute bytes for a single column at col (0..31)
' in the play area (rows 0..20) using direct POKE to the
' currently mapped attribute buffer.
' Rows 0..gap-1        -> ATTR_PIPE_SHADOW
' Rows gap..gap+GAP-1  -> ATTR_SKY
' Rows gap+GAP..19     -> ATTR_PIPE_SHADOW
' Row 20               -> ATTR_FLOOR
' ---------------------------------------------------------------
Sub writePipeColumn(col As Ubyte, gap As Ubyte, attr As Ubyte)
    If gap > 0 Then
        paint(col, 1, 1, gap, attr)
    End If
    paint(col, gap + 1, 1, PIPE_GAP_SIZE, ATTR_SKY)
    Dim pipeLow As Ubyte = 22 - gap - PIPE_GAP_SIZE
    If pipeLow > 0 Then
        paint(col, gap + PIPE_GAP_SIZE + 1, 1, pipeLow, attr)
    End If
    paint(col, 23, 1, 1, floorAttr())
End Sub

' ---------------------------------------------------------------
' writeSkyColumn col
' Fills column col with sky attr for rows 0..19, floor at row 20.
' ---------------------------------------------------------------
Sub writeSkyColumn(col As Ubyte)
    paint(col, 1, 1, 22, ATTR_SKY)
    paint(col, 23, 1, 1, floorAttr())
End Sub
' ---------------------------------------------------------------
' initPlayfield
' Clears play area pixels and attributes ready for a new game.
' ---------------------------------------------------------------
Sub initPlayfield()
    paint(0, 1, 32, 22, ATTR_SKY)
    Dim c As Ubyte
    For c = 0 To 31
        paint(c, 23, 1, 1, attrFloorTable(c Mod 3))
    Next c
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
    waitretrace
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