' ---------------------------------------------------------------
' Check collision: bird overlaps a pipe attr (ATTR_PIPE = 0x20)
' Read directly from attr buffer for speed.
' ---------------------------------------------------------------
Function checkBirdCollision(bx As Ubyte, by As Ubyte) As Ubyte
    Dim attrBuf(0) As Ubyte
    ' Check all 4 cells of the 2x2 bird for ATTR_PIPE
    getPaintData(bx, by, 1, 1, @attrBuf(0))
    If attrBuf(0) <> ATTR_SKY Then Return 1
    getPaintData(bx + 1, by, 1, 1, @attrBuf(0))
    If attrBuf(0) <> ATTR_SKY Then Return 1
    getPaintData(bx, by + 1, 1, 1, @attrBuf(0))
    If attrBuf(0) <> ATTR_SKY Then Return 1
    getPaintData(bx + 1, by + 1, 1, 1, @attrBuf(0))
    If attrBuf(0) <> ATTR_SKY Then Return 1
    Return 0
End Function