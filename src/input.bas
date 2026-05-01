Sub readKeyboard()
    If Inkey$<>"" Then
        birdVel = BIRD_JUMP_VEL
    End If
End Sub

Sub waitAnyKey()
    While Inkey$<>"":Wend
    While Inkey$="":Wend
End Sub