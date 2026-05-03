#include "playGameModule.bas"

Sub showPlayGameScreen(clearScreen As Ubyte)
    initGame(clearScreen)
    
    Do
        screenSync()
        
        readKeyboard()
        preserveYPosition()
        gravity()
        waitretrace
        scroll()
        redrawBird()
        checkScore()
        
        If checkBirdCollision(birdX, Int(birdYPos)) Then
            showGameOverScreen()
        End If
        ' waitAnyKey()
    Loop
End Sub
