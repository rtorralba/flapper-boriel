Function isSpacePressed() As Ubyte
    If MultiKeys(KEYSPACE) Then
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

Sub waitUntilSpaceReleased()
    Do
    Loop While isSpacePressed()
End Sub