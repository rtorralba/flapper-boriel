Function zeroPad3(n As UInteger) As String
    Dim s As String = Str$(n)
    While Len(s) < 3
        s = "0" + s
    Wend
    Return s
End Function

Sub playScoreFX()
    BEEP 0.005, 50
End Sub

Sub preserveYPosition()
    birdOldY = Int(birdYPos)
End Sub