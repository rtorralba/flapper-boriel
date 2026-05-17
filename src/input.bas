Sub readKeyboard()
    If Inkey$<>"" Then
        birdVel = BIRD_JUMP_VEL
    End If
End Sub

Sub waitKeyboardForOption()
    While Inkey$<>"":Wend
    Do
        While Inkey$="":Wend
        If Inkey$ <> "s" And Inkey$ <> "S" Then
            Exit Do
        Else
            toogleSpeedOption()
        End If
        ' If 's' was pressed, wait for release and continue waiting for a real key
        While Inkey$<>"":Wend
    Loop
End Sub