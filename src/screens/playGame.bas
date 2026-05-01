#include "playGameModule.bas"

Sub showPlayGameScreen(clearScreen As Ubyte)
    initGame(clearScreen)
    
    Do
        screenSync()
        
        readKeyboard()
        preserveYPosition()
        gravity()
        scroll()
        redrawBird()
        checkScore()

        If checkBirdCollision(birdX, Int(birdYPos)) Then
            showGameOverScreen()
        End If
    Loop
End Sub
