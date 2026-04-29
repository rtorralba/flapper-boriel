' Bird position (in 8px cells, range 0..31 X, 0..21 Y for 2-cell tall bird)
Dim mainCharacterX As Ubyte
Dim mainCharacterY As Ubyte
Dim mainCharacterOldY As Ubyte

' Blank 2x2 sprite (32 zero bytes) used to erase bird pixels without touching attrs
Dim blankSprite(31) As Ubyte => {0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0}

' Bird physics (fixed-point: velocity in 1/4 cell units)
Dim birdVelQ As Integer   ' velocity * 4 (positive = down)
Dim birdYAcc As Integer   ' sub-cell accumulator

' Pipe state
' pipeGap(i): row of the gap top for pipe slot i
Const NUM_PIPES As Ubyte = 2
Const PIPE_GAP_SIZE As Ubyte = 6
Const PIPE_WIDTH As Ubyte = 4
Const PIPE_SPAWN_INTERVAL As Ubyte = 18
Const PIPE_PERIOD As Ubyte = 36  ' 2 * PIPE_SPAWN_INTERVAL

Dim pipeGap(1) As Ubyte

' World scroll counter: how many columns have entered from the right
Dim worldCol As UInteger

' Score
Dim score As Ubyte
Dim hiScore As Ubyte

' Game state
Dim gameOver As Ubyte
Dim gameStarted As Ubyte