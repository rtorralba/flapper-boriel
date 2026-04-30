Function zeroPad3(n As UInteger) As String
    Dim s As String = Str$(n)
    While Len(s) < 3
        s = "0" + s
    Wend
    Return s
End Function

Sub playScoreFX()
    BEEP 0.05, 20
End Sub