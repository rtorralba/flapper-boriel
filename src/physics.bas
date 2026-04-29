Sub gravity()
    ' --- Physics ---
    birdVelQ = birdVelQ + 2
    If birdVelQ > 10 Then birdVelQ = 10
    If birdVelQ > 0 And birdYAcc < 0 Then birdYAcc = 0
    
    mainCharacterOldY = mainCharacterY
    
    Dim newY As Integer
    birdYAcc = birdYAcc + birdVelQ
    Dim dy As Integer = birdYAcc / 4
    birdYAcc = birdYAcc - dy * 4
    newY = mainCharacterY + dy
    If newY < 1 Then newY = 1
    If newY > 21 Then
        newY = 21
        gameOver = 1
    End If
    mainCharacterY = newY
End Sub