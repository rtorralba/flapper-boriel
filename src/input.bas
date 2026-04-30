Sub readKeyboard()
    If MultiKeys(KEYSPACE) Then
        birdVelQ = -7
        birdYAcc = 0
    End If
End Sub

Sub waitForSpace()
    Do
    Loop Until MultiKeys(KEYSPACE)
    Do
    Loop While MultiKeys(KEYSPACE)
End Sub