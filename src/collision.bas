' -------------------------------------------------------------------------------
' Check collision: returns 1 if any of the 2x2 pixels at (bx, by) are not sky.
' -------------------------------------------------------------------------------
Function checkBirdCollision(bx As Ubyte, by As Ubyte) As Ubyte
    Dim attrBuf(3) As Ubyte
    getPaintData(bx, by, 2, 2, @attrBuf(0))
    If attrBuf(0) <> ATTR_SKY Then Return 1
    If attrBuf(1) <> ATTR_SKY Then Return 1
    If attrBuf(2) <> ATTR_SKY Then Return 1
    If attrBuf(3) <> ATTR_SKY Then Return 1
    Return 0
End Function