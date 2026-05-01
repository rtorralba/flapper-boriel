Sub readKeyboard()
    If MultiKeys(KEYSPACE) Then
        birdVel = BIRD_JUMP_VEL
    End If
End Sub

Sub waitForSpace()
    Do
    Loop Until MultiKeys(KEYSPACE)
    Do
    Loop While MultiKeys(KEYSPACE)
End Sub