#include "playGameModule.bas"

Sub showPlayGameScreen(clearScreen As Ubyte)
    initGame(clearScreen)
    
    Do
        screenSync()
        
        readKeyboard()
        preserveYPosition()
        gravity()
        ' waitretrace
        scroll()
        
        If checkBirdCollision(birdX, Int(birdYPos)) Then
            redrawBird()
            showGameOverScreen()
        End If
        
        redrawBird()
        checkScore()
        ' waitAnyKey()
    Loop
End Sub
