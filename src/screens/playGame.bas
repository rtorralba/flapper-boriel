#include "playGameModule.bas"

Sub showPlayGameScreen(clearScreen As Ubyte)
    initGame(clearScreen)
    
    Do
        screenSync()
        
        readKeyboard()
        preserveYPosition()
        gravity()
        scroll()
        If checkBirdCollision(birdX, Int(birdYPos)) Then
            showGameOverScreen()
        End If
        
        checkScore()
    Loop
End Sub
