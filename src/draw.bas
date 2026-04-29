' ---------------------------------------------------------------
' Attribute constants
'   PAPER 1 (blue)  INK 0 = %00_001_000 = 8  -> sky
'   PAPER 4 (green) INK 0 = %00_100_000 = 32 -> pipe
'   PAPER 2 (red)   INK 2 = %00_010_010 = 18 -> floor
'
' All attribute writes target the standard screen at 0x5800.
' paint() from putchars.bas is used throughout (fast ASM, no POKE loops).
' scrollPlayfieldAttrs() is the only inline ASM (no library equivalent).
' ---------------------------------------------------------------

Const ATTR_SKY   As Ubyte = 8   ' Paper 1, Ink 0  = %00_001_000
Const ATTR_PIPE  As Ubyte = 32  ' Paper 4, Ink 0  = %00_100_000
Const ATTR_FLOOR As Ubyte = 18  ' Paper 2, Ink 2  = %00_010_010

' ---------------------------------------------------------------
' scrollPlayfieldAttrs
' Shifts the attribute bytes of rows 0..20 one cell LEFT using
' Z80 LDIR: each row is copied from col1..31 back to col0..30,
' leaving col 31 unchanged (caller fills it).
' Works on the CURRENTLY MAPPED attribute buffer.
' ---------------------------------------------------------------
Sub scrollPlayfieldAttrs()
    Asm
    PROC
    LOCAL scrollRow
        ld hl, $5801        ; src = attr row 0, col 1 (standard screen always $5800)
        ld de, $5800        ; dst = attr row 0, col 0
        ld b, 21            ; 21 rows (rows 0..20)
scrollRow:
        push bc
        ld bc, 31           ; copy 31 bytes: cols 1..31 -> 0..30
        ldir
        ; after ldir: HL = col 0 of next row, DE = col 31 of current row
        inc de              ; DE = col 0 of next row
        inc hl              ; HL = col 1 of next row
        pop bc
        djnz scrollRow
    ENDP
    End Asm
End Sub

' ---------------------------------------------------------------
' writeAttrColumn col, gap
' Writes attribute bytes for a single column at col (0..31)
' in the play area (rows 0..20) using direct POKE to the
' currently mapped attribute buffer.
' Rows 0..gap-1        -> ATTR_PIPE
' Rows gap..gap+GAP-1  -> ATTR_SKY
' Rows gap+GAP..19     -> ATTR_PIPE
' Row 20               -> ATTR_FLOOR
' ---------------------------------------------------------------
Sub writeAttrColumn(col As Ubyte, gap As Ubyte)
    If gap > 0 Then
        paint(col, 0, 1, gap, ATTR_PIPE)
    End If
    paint(col, gap, 1, PIPE_GAP_SIZE, ATTR_SKY)
    Dim pipeLow As Ubyte = 20 - gap - PIPE_GAP_SIZE
    If pipeLow > 0 Then
        paint(col, gap + PIPE_GAP_SIZE, 1, pipeLow, ATTR_PIPE)
    End If
    paint(col, 20, 1, 1, ATTR_FLOOR)
End Sub

' ---------------------------------------------------------------
' writeSkyColumn col
' Fills column col with sky attr for rows 0..19, floor at row 20.
' ---------------------------------------------------------------
Sub writeSkyColumn(col As Ubyte)
    paint(col, 0, 1, 20, ATTR_SKY)
    paint(col, 20, 1, 1, ATTR_FLOOR)
End Sub

' ---------------------------------------------------------------
' initPlayfield
' Clears play area pixels and attributes ready for a new game.
' ---------------------------------------------------------------
Sub initPlayfield()
    ' Zero pixel data (6144 bytes)
    Asm
        ld hl, (.core.SCREEN_ADDR)
        ld d, h
        ld e, l
        inc de
        ld bc, 6143
        ld (hl), 0
        ldir
    End Asm
    ' Fill attributes using paint() (targets 0x5800 directly, fast ASM)
    paint(0, 0, 32, 20, ATTR_SKY)
    paint(0, 20, 32, 1, ATTR_FLOOR)
End Sub

' ---------------------------------------------------------------
' Draw the bird sprite at current position with correct attributes
' ---------------------------------------------------------------
Sub drawMainCharacter()
    ' Only draw pixels - do NOT overwrite background attributes
    ' so collision detection can read pipe/sky attrs correctly.
    putChars(mainCharacterX, mainCharacterY, 2, 2, @sprite0(0))
End Sub

' ---------------------------------------------------------------
' Erase bird sprite at given position (restore sky attrs + blank pixels)
' ---------------------------------------------------------------
Sub eraseBird(bx As Ubyte, by As Ubyte)
    ' Zero out pixels only - no Print, no paint: attrs stay intact
    putChars(bx, by, 2, 2, @blankSprite(0))
End Sub

' ---------------------------------------------------------------
' Draw the HUD bar (rows 21-23) - called once at startup
' ---------------------------------------------------------------
Sub drawHUD()
    Dim c As Ubyte
    For c = 0 To 31
        Print At 21, c; Bright 0; INK 2; Paper 2; " "
    Next c
    Print At 22, 1; INK 7; Paper 0; "SCORE:"
    Print At 22, 14; INK 7; Paper 0; "BORIEL FLAPPER"
End Sub

' Update score display in HUD
Sub drawScore()
    Print At 22, 7; INK 6; Paper 0; score; "   "
End Sub

' Show game over message
Sub drawGameOver()
    Print At 8, 8;  INK 7; Paper 0; " GAME OVER  "
    Print At 10, 8; INK 6; Paper 0; " Score: "; score; "  "
    Print At 12, 8; INK 5; Paper 0; " Press SPACE "
End Sub

' Show start screen
Sub drawStartScreen()
    Print At 8,  9; INK 7; Paper 0; " BORIEL FLAPPER  "
    Print At 10, 9; INK 6; Paper 0; " Press SPACE "
End Sub