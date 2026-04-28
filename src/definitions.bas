' Bird position (in 8px cells, range 0..31 X, 0..21 Y for 2-cell tall bird)
Dim mainCharacterX As Ubyte
Dim mainCharacterY As Ubyte
Dim mainCharacterOldX As Ubyte
Dim mainCharacterOldY As Ubyte

' Attribute for bird: INK 7, Paper 1 = 1*8+7 = 15 (4 cells: 2x2)
Dim birdAttr(3) As Ubyte => { 15, 15, 15, 15 }

' Bird physics (fixed-point: velocity in 1/4 cell units)
Dim birdVelQ As Integer   ' velocity * 4 (positive = down)
Dim birdYAcc As Integer   ' sub-cell accumulator, carries fractional movement between frames

' Pipe state (two pipes on screen, each is a column)
' pipeX: cell column of the pipe (0..31)
' pipeGap: cell row of the gap top (0..19, gap is GAP_SIZE rows tall)
Const NUM_PIPES As Ubyte = 2
Const PIPE_GAP_SIZE As Ubyte = 6       ' gap height in cells
Const PIPE_WIDTH As Ubyte = 4          ' pipe width in cells
Const PIPE_SPAWN_INTERVAL As Ubyte = 18 ' cells between pipe columns

Dim pipeX(1) As Ubyte
Dim pipeGap(1) As Ubyte
Dim pipeActive(1) As Ubyte

' Double-buffer shadow positions (index = buffer: 0=bank5, 1=bank7)
Dim shadowBirdX(1) As Ubyte
Dim shadowBirdY(1) As Ubyte
Dim shadowPipeX0(1) As Ubyte   ' per-buffer X of pipe 0
Dim shadowPipeX1(1) As Ubyte   ' per-buffer X of pipe 1

' Score
Dim score As Ubyte

' Game state
Dim gameOver As Ubyte
Dim gameStarted As Ubyte