#include "playGameModule.bas"

Sub showPlayGameScreen()
    initGame()
    
    Do
        screenSync()
        
        readKeyboard()
        gravity()
        scroll()
        redrawMainCharacter()
        checkScore()

        If checkBirdCollision(mainCharacterX, mainCharacterY) Then
            showGameOverScreen()
        End If
    Loop
End Sub
