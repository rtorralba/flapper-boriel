Function checkBirdCollision(bx As Ubyte, by As Ubyte) As Ubyte
    Dim pX As Integer
    Dim gap As Ubyte
    Dim front As Ubyte

    ' Floor: play area ends at row 22
    If by + 1 > 22 Then Return 1

    ' Selecciona la pipe delantera: la activa con menor pX (más cerca del pájaro)
    If pipeActive(0) And pipeActive(1) Then
        If pipeX(0) <= pipeX(1) Then
            front = 0
        Else
            front = 1
        End If
    ElseIf pipeActive(0) Then
        front = 0
    ElseIf pipeActive(1) Then
        front = 1
    Else
        Return 0
    End If

    ' Guard horizontal: si no solapa en X no puede colisionar
    pX = pipeX(front)
    If Int(bx) + 1 < pX Or Int(bx) > pX + PIPE_WIDTH - 1 Then Return 0

    ' Hay solapamiento: el pájaro debe estar enteramente en el hueco
    gap = pipeGap(front)
    If by <= gap Then Return 1
    If Int(by) + 1 > Int(gap) + PIPE_GAP_SIZE Then Return 1
    Return 0
End Function