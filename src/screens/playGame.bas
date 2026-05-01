#include "playGameModule.bas"

Sub showPlayGameScreen(clearScreen As Ubyte)
    initGame(clearScreen)
    
    Do
        screenSync()
        
        readKeyboard()
        preserveYPosition()
        gravity()
        scroll()
        redrawMainCharacter()
        checkScore()

        If checkBirdCollision(mainCharacterX, mainCharacterY) Then
            showGameOverScreen()
        End If
    Loop
End Sub
