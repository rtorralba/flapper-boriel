Function isSpacePressed() As Ubyte
    If Inkey$ = " " Then
        Return 1
    End If
    Return 0
End Function

Sub readKeyboard()
    If isSpacePressed() Then
        birdVelQ = -7
        birdYAcc = 0
    End If
End Sub