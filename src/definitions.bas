Const ATTR_SKY          As Ubyte = 14   ' Paper 1, Ink 6        = %00_001_110
Const ATTR_PIPE         As Ubyte = 102 ' Paper 4, Ink 6, bright = %01_100_110
Const ATTR_PIPE_SHADOW  As Ubyte = 38   ' Paper 4, Ink 6, matte = %00_100_110

Const ATTR_FLOOR_0 As Ubyte = 18  ' Ink 2, Paper 2, matte red/red
Const ATTR_FLOOR_0_HALF As Ubyte = 26  ' Ink 2, Paper 3, matte red/magenta
Const ATTR_FLOOR_1 As Ubyte = 27  ' Ink 3, Paper 3, matte magenta/magenta
Const ATTR_FLOOR_1_HALF As Ubyte = 51  ' Ink 3, Paper 6, matte magenta/yellow
Const ATTR_FLOOR_2 As Ubyte = 54  ' Ink 6, Paper 6, matte yellow/yellow
Const ATTR_FLOOR_2_HALF As Ubyte = 22  ' Ink 6, Paper 2, matte yellow/red

Dim attrFloorFullTable(2) As Ubyte => {ATTR_FLOOR_0, ATTR_FLOOR_1, ATTR_FLOOR_2}
Dim attrFloorHalfTable(2) As Ubyte => {ATTR_FLOOR_0_HALF, ATTR_FLOOR_1_HALF, ATTR_FLOOR_2_HALF}

' Pipe state
' pipeGap(i): row of the gap top for pipe slot i
Const NUM_PIPES As Ubyte = 2
Const PIPE_GAP_SIZE As Ubyte = 6
Const PIPE_WIDTH As Ubyte = 5
Const PIPE_SPAWN_INTERVAL As Ubyte = 18
Const PIPE_PERIOD As Ubyte = 36  ' 2 * PIPE_SPAWN_INTERVAL

Const BIRD_INITIAL_X As Ubyte = 4
Const BIRD_INITIAL_Y As Ubyte = 10

' Bird position (in 8px cells, range 0..31 X, 0..21 Y for 2-cell tall bird)
Dim birdX    As Ubyte
Dim birdOldY As Ubyte

' Blank 2x2 sprite (32 zero bytes) used to erase bird pixels without touching attrs
Dim blankSprite(31) As Ubyte => {0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0}

' Half-block tile: left 4 pixels ON ($F0) on every scanline — used for half-char drawing
Dim halfTile(7) As Ubyte => {$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0}

Dim currentFloorTile As Integer

' Bird physics (fixed point: velocity in cells/frame)
Const BIRD_GRAVITY     As Fixed = 0.30  ' acceleration per frame
Const BIRD_MAX_VEL     As Fixed = 1.5   ' terminal velocity (cells/frame)
Const BIRD_JUMP_VEL    As Fixed = -1.0  ' velocity applied on jump
Const BIRD_INITIAL_VEL As Fixed = 0.25  ' velocity at game start

Dim birdVel  As Fixed   ' velocity in cells/frame (positive = down)
Dim birdYPos As Fixed   ' Y position as fixed point

Dim pipeGap(1) As Ubyte

' World scroll counter: how many columns have entered from the right
Dim worldCol As UInteger

' Score
Dim score As Ubyte
Dim hiScore As Ubyte