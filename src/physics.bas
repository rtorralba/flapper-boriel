Sub checkLimits()
    If Int(birdYPos) < 1 Then
        birdYPos = 1.0
        Return
    End If
    If Int(birdYPos) > 21 Then
        birdYPos = 22.0
        Return
    End If
End Sub

Function setNewSpeed() As Fixed
    birdVel = birdVel + BIRD_GRAVITY
    If birdVel > BIRD_MAX_VEL Then birdVel = BIRD_MAX_VEL
End Function

Sub gravity()
    setNewSpeed()

    birdYPos = birdYPos + birdVel

    checkLimits()
End Sub