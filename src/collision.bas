' ---------------------------------------------------------------
' Check collision: bird overlaps a pipe attr (ATTR_PIPE_SHADOW = 0x20)
' Read directly from attr buffer for speed.
' ---------------------------------------------------------------
Function checkBirdCollision(bx As Ubyte, by As Ubyte) As Ubyte
    Dim attrBuf(3) As Ubyte
    getPaintData(bx, by, 2, 2, @attrBuf(0))
    If attrBuf(0) <> ATTR_SKY Then Return 1
    If attrBuf(1) <> ATTR_SKY Then Return 1
    If attrBuf(2) <> ATTR_SKY Then Return 1
    If attrBuf(3) <> ATTR_SKY Then Return 1
    Return 0
End Function