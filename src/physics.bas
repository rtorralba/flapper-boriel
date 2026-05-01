Function checkLimits(newY As Integer) As Integer
    If newY < 1 Then
        birdYPos = 1.0
        Return 1
    End If
    If newY > 21 Then
        birdYPos = 22.0
        Return 22
    End If
    Return newY
End Function

Sub gravity()
    mainCharacterOldY = mainCharacterY

    birdVel = birdVel + BIRD_GRAVITY
    If birdVel > BIRD_MAX_VEL Then birdVel = BIRD_MAX_VEL

    birdYPos = birdYPos + birdVel

    mainCharacterY = checkLimits(Int(birdYPos))
End Sub