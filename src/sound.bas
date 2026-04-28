' Play a two-tone "score" FX on the AY chip
Sub playScoreFX()
    Asm
        LOCAL sfxWait1, sfxOuter1, sfxWait2, sfxOuter2

        ; --- Note 1: channel A, period 40 (~1562 Hz) ---
        LD BC, $FFFD
        LD A, 0             ; reg 0 = channel A tone period low
        OUT (C), A
        LD BC, $BFFD
        LD A, 40
        OUT (C), A

        LD BC, $FFFD
        LD A, 1             ; reg 1 = channel A tone period high
        OUT (C), A
        LD BC, $BFFD
        XOR A
        OUT (C), A

        LD BC, $FFFD
        LD A, 7             ; mixer: channel A tone on, rest off
        OUT (C), A
        LD BC, $BFFD
        LD A, %00111110
        OUT (C), A

        LD BC, $FFFD
        LD A, 8             ; channel A volume = max
        OUT (C), A
        LD BC, $BFFD
        LD A, 15
        OUT (C), A

        ; delay ~0.1s
        LD D, 25
sfxOuter1:
        LD B, 0
sfxWait1:
        DJNZ sfxWait1
        DEC D
        JR NZ, sfxOuter1

        ; --- Note 2: period 25 (~2500 Hz) ---
        LD BC, $FFFD
        LD A, 0
        OUT (C), A
        LD BC, $BFFD
        LD A, 25
        OUT (C), A

        ; delay ~0.1s
        LD D, 25
sfxOuter2:
        LD B, 0
sfxWait2:
        DJNZ sfxWait2
        DEC D
        JR NZ, sfxOuter2

        ; --- Silence ---
        LD BC, $FFFD
        LD A, 8
        OUT (C), A
        LD BC, $BFFD
        XOR A
        OUT (C), A
    End Asm
End Sub
