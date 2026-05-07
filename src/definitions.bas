Const ATTR_SKY          As Ubyte = 9
Const ATTR_PIPE         As Ubyte = 36
Const ATTR_FIRST_HALF   As Ubyte = 33
Const ATTR_LAST_HALF    As Ubyte = 12

' Precalculated floor attribute phases for maximum speed (6 variations)
Dim floorAttrPhases(5, 31) As Ubyte => { _
    { 18, 27, 54, 18, 27, 54, 18, 27, 54, 18, 27, 54, 18, 27, 54, 18, 27, 54, 18, 27, 54, 18, 27, 54, 18, 27, 54, 18, 27, 54, 18, 27 }, _
    { 26, 51, 22, 26, 51, 22, 26, 51, 22, 26, 51, 22, 26, 51, 22, 26, 51, 22, 26, 51, 22, 26, 51, 22, 26, 51, 22, 26, 51, 22, 26, 51 }, _
    { 27, 54, 18, 27, 54, 18, 27, 54, 18, 27, 54, 18, 27, 54, 18, 27, 54, 18, 27, 54, 18, 27, 54, 18, 27, 54, 18, 27, 54, 18, 27, 54 }, _
    { 51, 22, 26, 51, 22, 26, 51, 22, 26, 51, 22, 26, 51, 22, 26, 51, 22, 26, 51, 22, 26, 51, 22, 26, 51, 22, 26, 51, 22, 26, 51, 22 }, _
    { 54, 18, 27, 54, 18, 27, 54, 18, 27, 54, 18, 27, 54, 18, 27, 54, 18, 27, 54, 18, 27, 54, 18, 27, 54, 18, 27, 54, 18, 27, 54, 18 }, _
    { 22, 26, 51, 22, 26, 51, 22, 26, 51, 22, 26, 51, 22, 26, 51, 22, 26, 51, 22, 26, 51, 22, 26, 51, 22, 26, 51, 22, 26, 51, 22, 26 } _
}

' Pipe state
' pipeGap(i): row of the gap top for pipe slot i
Const NUM_PIPES As Ubyte = 2
Const PIPE_GAP_SIZE As Ubyte = 6
Const PIPE_WIDTH As Ubyte = 5
Const PIPE_SPAWN_INTERVAL As Ubyte = 36
Const PIPE_PERIOD As Ubyte = 72  ' 2 * PIPE_SPAWN_INTERVAL

Const BIRD_INITIAL_X As Ubyte = 4
Const BIRD_INITIAL_Y As Ubyte = 10

' Bird position (in 8px cells, range 0..31 X, 0..21 Y for 2-cell tall bird)
Dim birdX    As Ubyte
Dim birdOldY As Ubyte

' Blank 2x2 sprite (32 zero bytes) used to erase bird pixels without touching attrs
Dim blankSprite(31) As Ubyte => {0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0}

' Half-block tile: left 4 pixels ON ($F0) on every scanline — used for half-char drawing
Dim halfTile(7) As Ubyte => {$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0}
Dim emptyTile(7) As Ubyte => {0,0,0,0,0,0,0,0}

Dim currentFloorTile As Integer

' Bird physics (fixed point: velocity in cells/frame)
Const BIRD_GRAVITY     As Fixed = 0.20  ' acceleration per frame
Const BIRD_MAX_VEL     As Fixed = 1.5   ' terminal velocity (cells/frame)
Const BIRD_JUMP_VEL    As Fixed = -0.75  ' velocity applied on jump
Const BIRD_INITIAL_VEL As Fixed = 0.25  ' velocity at game start

Dim birdVel  As Fixed   ' velocity in cells/frame (positive = down)
Dim birdYPos As Fixed   ' Y position as fixed point

Dim pipeGap(1) As Ubyte
Dim nextPipeGap(1) As Ubyte
Dim pipeX(1) As Integer
Dim pipeActive(1) As Ubyte

' Screen attribute buffer for rows 1..23 (736 bytes).
' calculatePipes writes columns 1..22 here; paintPipes copies row 23 (floor)
' then does a single memcopy of all 736 bytes to attribute RAM at 22560.
' Index for row r (1..22), col c (0..31) = (r-1)*32 + c
' Floor row 23 occupies indices 704..735.
Dim screenBuffer(735) As Ubyte

' World scroll counter: how many columns have entered from the right
Dim worldCol As UInteger

' Score
Dim score As Ubyte
Dim hiScore As Ubyte