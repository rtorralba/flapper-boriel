<!-- Technical overview of Flapper Boriel: program flow and key functions -->
# Flapper Boriel — Technical Overview

This document explains the runtime flow and the main functions/modules of the `flapper-boriel` port, intended as a friendly technical write-up for developers.

## High-level architecture

- Entry point: `src/main.bas` — includes libraries, core modules, and the game screens. The program starts by calling `showMenuScreen()`.
- Screens: `src/screens/` contains the high-level screens: `menu.bas`, `playGame.bas`, and `gameOver.bas`. Each screen exposes a function to show the screen and handles its own input/flow.
- Modules: core logic is split across modules in `src/`: `definitions.bas` (constants / global vars), `functions.bas` (utility helpers), `spriteset.bas` (sprite data), `input.bas`, `physics.bas`, `draw.bas`, and `collision.bas`.

## Main game loop (play screen)

The active gameplay loop lives in `src/screens/playGame.bas` inside `showPlayGameScreen()`:

1. `initGame(clearScreen)` — sets up initial variables, calls `initPlayfield()` and `drawHUD()`, and draws the initial bird.
2. Loop:
   - `screenSync()` — waits for retrace to cap/align frame rate.
   - `readKeyboard()` — reads player input; if a key is pressed a jump velocity is applied.
   - `preserveYPosition()` — stores previous bird Y to support smooth redraw.
   - `gravity()` — applies physics to update bird velocity and position.
   - `scroll()` — advances the world by one column (attributes + drawing new last column).
   - `redrawBird()` — erases the old bird sprite and draws it at the new position (pixel-only updates so attributes remain for collision checks).
   - `checkScore()` — increments score when pipes pass a scoring column and adjusts future pipe gaps.
   - `checkBirdCollision(birdX, Int(birdYPos))` — if collision detected, transition to game over screen.

This tight sequence implements a deterministic per-frame update: input → physics → world scroll → render → collision/score.

## Important files & functions

- `src/definitions.bas`
  - Holds constants (colors, pipe geometry, bird physics constants), global state variables like `birdX`, `birdYPos`, `worldCol`, `pipeGap[]`, and `score`.

- `src/input.bas`
  - `readKeyboard()` — checks `Inkey$` and applies `BIRD_JUMP_VEL` to `birdVel` on keypress.
  - `waitAnyKey()` — helper used on menu / game-over screens to wait for a key press.

- `src/physics.bas`
  - `gravity()` — calls `setNewSpeed()` then moves `birdYPos` by `birdVel` and clamps via `checkLimits()`.
  - `setNewSpeed()` — increases `birdVel` by `BIRD_GRAVITY` and clamps to `BIRD_MAX_VEL`.
  - `checkLimits()` — keeps the bird within allowed rows (prevents leaving the playfield).

- `src/draw.bas`
  - Playfield attribute management and sprite blitting live here.
  - `initPlayfield()` — clears play area attributes/pixels and paints the floor pattern from `attrFloorTable`.
  - `drawHUD()`, `drawScore()`, `drawHiScore()` — draw the top HUD and update score displays.
  - Bird rendering:
    - `drawBird()` — draws the 16×16 bird sprite pixels using `putChars` but does not overwrite attribute bytes (so collisions read correct attributes).
    - `eraseBird(bx, by)` — writes a blank 2×2 character sprite to remove pixels without touching attributes.
    - `redrawBird()` — waits retrace, erases old bird, and draws new bird.
  - World scrolling & columns:
    - `scrollPlayfieldAttrs()` — moves the playfield attribute bytes left by one column using block memory moves.
    - `paintLastColumn()` — computes what to paint on the right-most column (pipes or sky) based on `worldCol` and pipe timing.
    - `scroll()` — wrapper that calls `scrollPlayfieldAttrs()`, `paintLastColumn()` and increments `worldCol`.
  - Pipe/sky drawing primitives:
    - `writePipeColumn(col, gap, attr)` — paints a column containing pipe segments, gap area, and the floor attribute at the bottom.
    - `writeSkyColumn(col)` — fills a column with sky attributes + floor at bottom.
    - `floorAttr()` — returns the floor attribute based on `worldCol` to create a simple floor pattern using `attrFloorTable`.

- `src/collision.bas`
  - `checkBirdCollision(bx, by)` — reads the 2×2 attribute bytes at the bird's tile position using `getPaintData()` and returns collision if any byte is not `ATTR_SKY`.

- `src/functions.bas`
  - Small helpers: `zeroPad3(n)` for score formatting, `playScoreFX()` to play a short beep on scoring, and `preserveYPosition()`.

- `src/spriteset.bas`
  - Contains generated sprite bytes for the bird and a `blankSprite` used for erasing.

## Scoring & pipe lifecycle

- Pipes are defined by `PIPE_WIDTH`, `PIPE_SPAWN_INTERVAL` and `PIPE_PERIOD` (in `definitions.bas`). Two interleaved pipe slots create the obstacle rhythm.
- `worldCol` is a global column counter (increments each call to `scroll()`) used to decide whether the last column is pipe or sky.
- `checkScore()` inspects `worldCol % PIPE_PERIOD` and increments score when a trailing pipe column arrives at a scoring column. It also randomizes the next gap position deterministically from `score`.

## Rendering notes & collision model

- The renderer separates pixel data from attribute bytes (paper/ink). Bird drawing only writes pixel bytes (`putChars`) while leaving attribute bytes intact. This allows `checkBirdCollision()` to detect collisions purely from attributes (pipe/floor/sky), avoiding per-pixel collision math.
- `scrollPlayfieldAttrs()` shifts attribute bytes (color information) and `paintLastColumn()` writes the correct attribute bytes for pipes/sky/floor, ensuring collision tests remain consistent with what players see.

## Where to look next in the code

- Game bootstrap: `src/main.bas`
- Play loop and lifecycle: `src/screens/playGame.bas` and `src/screens/playGameModule.bas`
- Rendering + attribute logic: `src/draw.bas`
- Collision: `src/collision.bas`
- Physics & input: `src/physics.bas`, `src/input.bas`

## Closing notes

This project keeps logic intentionally small and modular so each part is easy to inspect and reuse. If you want, I can:

- add inline diagrams or ASCII flowcharts, or
- generate a function index with source links to lines for quick navigation.

---
Generated summary for contributors and blog readers; drop feedback or requests for more depth on any module.

## Code examples

Below are small, copy-pastable examples extracted from the codebase to illustrate common tasks: showing the play screen (game loop), collision detection, and world scrolling.

### Show a screen (game loop)

```bas
Sub showPlayGameScreen(clearScreen As Ubyte)
  initGame(clearScreen)
  Do
    screenSync()
    readKeyboard()
    preserveYPosition()
    gravity()
    scroll()
    redrawBird()
    checkScore()

    If checkBirdCollision(birdX, Int(birdYPos)) Then
      showGameOverScreen()
    End If
  Loop
End Sub
```

This sequence is the per-frame update: input → physics → world scroll → render → collision/score.

### Collision detection (attribute-based)

```bas
Function checkBirdCollision(bx As Ubyte, by As Ubyte) As Ubyte
  Dim attrBuf(3) As Ubyte
  getPaintData(bx, by, 2, 2, @attrBuf(0))
  If attrBuf(0) <> ATTR_SKY Then Return 1
  If attrBuf(1) <> ATTR_SKY Then Return 1
  If attrBuf(2) <> ATTR_SKY Then Return 1
  If attrBuf(3) <> ATTR_SKY Then Return 1
  Return 0
End Function
```

Collision is computed by reading the 2×2 attribute bytes at the bird's tile and checking for anything different than `ATTR_SKY`.

### World scroll (attributes + last column)

```bas
Sub scrollPlayfieldAttrs()
  Dim row As Ubyte
  Dim src As UInteger = $5821
  Dim dst As UInteger = $5820
  For row = 0 To 23
    MemMove(src, dst, 31)
    src = src + 32
    dst = dst + 32
  Next row
End Sub

Sub paintLastColumn()
  Dim wc As Ubyte = worldCol Mod PIPE_PERIOD
  Dim attribute As Ubyte = ATTR_PIPE
  Dim pipeLastCol As Ubyte = PIPE_WIDTH - 1

  If wc < PIPE_WIDTH Then
    If wc = pipeLastCol Then attribute = ATTR_PIPE_SHADOW
    writePipeColumn(31, pipeGap(0), attribute)
    Return
  End If

  If wc >= PIPE_SPAWN_INTERVAL Then
    If wc < PIPE_SPAWN_INTERVAL + PIPE_WIDTH Then
      If wc - PIPE_SPAWN_INTERVAL = pipeLastCol Then attribute = ATTR_PIPE_SHADOW
      writePipeColumn(31, pipeGap(1), attribute)
      Return
    End If
  End If

  writeSkyColumn(31)
End Sub

Sub scroll()
  scrollPlayfieldAttrs()
  paintLastColumn()
  worldCol = worldCol + 1
End Sub
```

The code shifts the attribute buffer left, paints a new right-most column (pipe or sky) based on `worldCol`, and increments the global column counter.

### Drawing / erasing the bird (pixels only)

```bas
Sub eraseBird(bx As Ubyte, by As Ubyte)
  putChars(bx, by, 2, 2, @blankSprite(0))
End Sub

Sub drawBird()
  putChars(birdX, Int(birdYPos), 2, 2, @sprite0(0))
End Sub

Sub redrawBird()
  waitretrace
  eraseBird(birdX, birdOldY)
  drawBird()
End Sub
```

Note: drawing only writes pixel bytes; attributes are preserved for correct collision detection. A `waitretrace` is used before `redrawBird()` to avoid sprite flicker when erasing and drawing the sprite.

## More information

For more information: [github.com/rtorralba/flapper-boriel](https://github.com/rtorralba/flapper-boriel)
