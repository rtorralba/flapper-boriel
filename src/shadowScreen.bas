
Dim currentVisibleScreen As Ubyte = 5
Dim currentBank As Ubyte = 5
Dim isShadowScreenActive As Ubyte = 0

Sub activateShadowScreen()
    SetScreenBufferAddr($c000)
    SetAttrBufferAddr($d800)
    isShadowScreenActive = 1
End Sub

Sub deactivateShadowScreen()
    SetScreenBufferAddr($4000)
    SetAttrBufferAddr($5800)
    isShadowScreenActive = 0
End Sub

Sub toggleScreen()
    If (currentVisibleScreen = 5) Then
        SetScreen(7)
        currentVisibleScreen = 7
    Else
        SetScreen(5)
        currentVisibleScreen = 5
    End If
End Sub

Sub switchBankToDrawHidden()
    If (currentVisibleScreen = 5) Then
        SetBank(7)
        currentBank = 7
    Else
        SetBank(5)
        currentBank = 5
    End If
End Sub

' ----------------------------------------------------------------
' Shows the screen placed in bankNumber = 5 or 7
' and updates the system variable BANKM.
' Only works on 128K and compatible models.
' Parameters:
'     bankNumber (UByte): Bank number where screen is
Sub Fastcall SetScreen(bankNumber AS UByte)
    Asm
        ; A = bankNumber to place at $c000
        and %00000010
        rlca
        rlca; A = %0000x000, bit3 = x = 0 or 1 for bankNumber = 5 or 7
        ld d,a
        ld a,($5b5c)       ; Read BANKM system variable
        and %11110111       ; Reset bank bits
        or d                ; Set bank bits to screenNumber
        ld bc,$7ffd         ; Memory Bank control port
        di                  ; Disable interrupts
        ld ($5b5c),a         ; Update BANKM system variable
        out (c),a           ; Set the bank
        ei                  ; Enable interrupts
    End Asm
End Sub