' Bell-like score FX: high tone with AY hardware envelope decay
Sub playScoreFX()
    Asm
        ; Set tone period for channel A: period 20 (~3906 Hz, bell-ish)
        LD BC, $FFFD
        LD A, 0
        OUT (C), A
        LD BC, $BFFD
        LD A, 20
        OUT (C), A

        LD BC, $FFFD
        LD A, 1
        OUT (C), A
        LD BC, $BFFD
        XOR A
        OUT (C), A

        ; Mixer: channel A tone on
        LD BC, $FFFD
        LD A, 7
        OUT (C), A
        LD BC, $BFFD
        LD A, %00111110
        OUT (C), A

        ; Envelope period low (reg 11): longer decay
        LD BC, $FFFD
        LD A, 11
        OUT (C), A
        LD BC, $BFFD
        LD A, 0
        OUT (C), A

        ; Envelope period high (reg 12)
        LD BC, $FFFD
        LD A, 12
        OUT (C), A
        LD BC, $BFFD
        LD A, 6
        OUT (C), A

        ; Envelope shape (reg 13): 0x09 = single decay (\)
        LD BC, $FFFD
        LD A, 13
        OUT (C), A
        LD BC, $BFFD
        LD A, $09
        OUT (C), A

        ; Channel A volume: use envelope (bit4=1)
        LD BC, $FFFD
        LD A, 8
        OUT (C), A
        LD BC, $BFFD
        LD A, $10
        OUT (C), A

        ; Envelope shape triggers automatically - no need to wait, AY decays on its own
    End Asm
End Sub
