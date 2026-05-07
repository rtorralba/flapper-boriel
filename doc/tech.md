# Español / English

## Español

Portar un BASIC compacto de Sinclair a Boriel BASIC es una lección en traducir restricciones: las ideas de juego son pequeñas y claras, pero el timing, el mapeado de memoria y unos pocos primitivos auxiliares cambian cómo se implementan. Me centré en tres objetivos:

- preservar la sensación original (timing, ritmo de las tuberías)
- mantener el código modular y legible para quien quiera aprender
- aplicar cambios mínimos en tiempo de ejecución cuando Boriel se comportaba diferente

A continuación explico las decisiones principales y muestro pequeños fragmentos de código para que puedas seguir o reutilizar las técnicas.

<img src="https://github.com/rtorralba/flapper-boriel/blob/main/doc/itchio/screenshoot_1.gif?raw=true" alt="Flapper gameplay" width="800">

### ¿Por qué esta estructura?

Separar entrada, física, render y colisión hizo que portar fuese sobre todo afinar constantes y pequeños cambios específicos de la plataforma (no reescribir la jugabilidad). Esa separación también facilita explicar el código: cada concepto está en una función pequeña.

### Latido por frame (en palabras)

El juego ejecuta un bucle por frame simple y predecible: leer entrada, actualizar física, desplazar el mundo, dibujar el pájaro, y luego comprobar colisiones y puntuación. Ese orden mantiene el comportamiento determinista —muy útil para ajustar el ritmo al portar.

En la práctica, el bucle es corto y claro y está compuesto por helpers pequeños: `screenSync()`, `readKeyboard()`, `gravity()`, `scroll()`, `redrawBird()`, `checkScore()`, `checkBirdCollision()`.

### Módulos clave y cambios

- `definitions.bas` — perillas de ajuste: gravedad, geometría de tuberías y atributos de pantalla.
- `physics.bas` — movimiento en punto fijo; matemáticas sencillas y fáciles de tunear.
- `draw.bas` — separé los bytes de atributos (color) de los datos de píxeles; eso simplificó la colisión y borrar/dibujar el pájaro.
- `collision.bas` — colisión basada en atributos: rápida y conceptualmente simple.

Rara vez fue necesario reescribir lógica algorítmica; la mayoría del trabajo fue ajustar timings y asegurar que las escrituras al buffer de atributos coincidieran con el mapeo de Boriel.

### Puntuación y ritmo de las tuberías

Las tuberías se generan con dos ranuras entrelazadas usando un único contador `worldCol`. Esta única fuente de timing mantiene sincronizado dibujo, puntuación y el patrón del suelo. El resultado es un ritmo predecible que encajó bien tras un par de pasadas de ajuste.

<img src="https://github.com/rtorralba/flapper-boriel/blob/main/doc/itchio/screenshoot_2.gif?raw=true" alt="Flapper gameplay" width="800">

### Render y colisión — la elección práctica

Elegí la colisión basada en atributos para evitar máscaras por píxel en el pájaro. El pájaro escribe solo píxeles, dejando los atributos intactos; la colisión es simplemente "¿la caja de atributos 2×2 en la posición del pájaro contiene algo distinto de `ATTR_SKY`?".

Este diseño es barato, robusto y fácil de explicar a quien lea el código por primera vez.

<img src="https://github.com/rtorralba/flapper-boriel/blob/main/doc/itchio/screenshoot_3.gif?raw=true" alt="Flapper gameplay" width="800">

### Nota de rendimiento

El timing en Boriel requirió un ajuste pragmático: la build Boriel en este repo se ralentiza por un factor 4 para que la velocidad de juego coincida con la original. Ese cambio es únicamente de tiempo de ejecución para preservar la experiencia.

### Conclusiones — lecciones para quien porte juegos

- Mantén la lógica de juego separada del rendering y el 'glue' de plataforma.
- Usa colisión por atributos en sistemas con capas de carácter/atributo; suele ser más simple y rápido.
- Ajusta constantes al final — la mayoría de bugs al portar son de timing, no algorítmicos.

## Ejemplos de código (Español)

Abajo hay ejemplos pequeños extraídos del código para ilustrar tareas comunes: mostrar la pantalla de juego, detección de colisión y desplazamiento del mundo.

### Mostrar la pantalla (bucle de juego)

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

Esta secuencia es la actualización por frame: entrada → física → desplazamiento del mundo → render → colisión/puntuación.

### Detección de colisión (por atributos)

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

La colisión se calcula leyendo los 2×2 bytes de atributos en la posición del pájaro y comprobando si hay algo distinto de `ATTR_SKY`.

### Desplazamiento del mundo (atributos + última columna)

Detalle de implementación: al desplazar el playfield movemos los bytes de atributos fila a fila (usando `MemMove` por fila) en lugar de mover toda la memoria de atributos de golpe. Hacerlo por fila evita que aparezca "basura" temporal en la columna más a la derecha por solapamiento de regiones en la memoria.

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

El código desplaza el buffer de atributos a la izquierda, pinta la nueva columna derecha (tubería o cielo) según `worldCol` y aumenta el contador global.

### Dibujar / borrar el pájaro (solo píxeles)

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

Nota: dibujar solo escribe bytes de píxeles; los atributos se preservan para una colisión correcta. Se usa `waitretrace` antes de `redrawBird()` para evitar parpadeo al borrar y dibujar el sprite.

### Más información

Para más información: [github.com/rtorralba/flapper-boriel](https://github.com/rtorralba/flapper-boriel)

---

## English

Porting a compact Sinclair BASIC to Boriel BASIC is a lesson in constraint translation: the gameplay ideas are tiny and clear, but timing, memory layout and a few helper primitives change how you implement them. I focused on three goals:

- preserve the original feel (timing, pipe rhythm)
- keep code modular and readable for learners
- make minimal runtime changes where Boriel behaved differently

Below I narrate the main decisions and share small code samples so you can follow along or reuse the techniques.

<img src="https://github.com/rtorralba/flapper-boriel/blob/main/doc/itchio/screenshoot_1.gif?raw=true" alt="Flapper gameplay" width="800">

## Why this structure? (short answer)

Keeping input, physics, rendering and collision logically separated made the porting work mostly about tuning constants and a couple of small platform-specific changes (not rewriting gameplay). That separation also makes the code easier to showcase in a blog post: each concept maps to a small function.

## The per-frame heartbeat (in plain words)

The game runs a simple, predictable frame loop: read input, update physics, scroll the world, draw the bird, then check collisions and scoring. That ordering keeps behavior deterministic — which helped a lot when I slowed the Boriel build to match Sinclair timing.

Practically speaking, the loop is short and readable and composed of these small helpers: `screenSync()`, `readKeyboard()`, `gravity()`, `scroll()`, `redrawBird()`, `checkScore()`, `checkBirdCollision()`.

## Key modules and what changed

- `definitions.bas` — tuning knobs: gravity, pipe geometry and display attributes live here.
- `physics.bas` — fixed-point motion; tiny math, easy to tweak.
- `draw.bas` — here I separated attribute (color) bytes from pixel data; that choice simplified collision and made erasing/drawing the bird straightforward.
- `collision.bas` — attribute-based collision: fast and conceptually simple.

I rarely had to rewrite algorithmic logic; most work was adjusting timings and ensuring the attribute buffer writes matched Boriel's memory mapping.

## Scoring & pipe rhythm

Pipes are generated by two interleaved slots using a single `worldCol` counter. This single timing source keeps pipe drawing, scoring and floor patterning in sync. The result is a predictable rhythm that felt right after a couple of tuning passes.

<img src="https://github.com/rtorralba/flapper-boriel/blob/main/doc/itchio/screenshoot_2.gif?raw=true" alt="Flapper gameplay" width="800">

## Rendering and collision — the practical choice

I chose attribute-based collision so we could avoid per-pixel masks on the bird. The bird writes pixels only, leaving attributes unchanged; collision is simply "does the 2×2 attribute box at the bird's position contain anything but `ATTR_SKY`?".

This design is cheap, robust and very easy to explain to someone reading the code for the first time.

<img src="https://github.com/rtorralba/flapper-boriel/blob/main/doc/itchio/screenshoot_3.gif?raw=true" alt="Flapper gameplay" width="800">

## Performance note

Boriel timings required a pragmatic tweak: the Boriel build in this repo is slowed by a factor of 4 so gameplay speed matches expectations from the original. That change is purely a runtime tuning to preserve player experience.

## Final thoughts — lessons for porters

- Keep gameplay logic separate from rendering and platform glue.
- Use attribute-based collision on systems with character/attribute layers; it's often simpler and faster.
- Tune constants last — most porting bugs are timing-related, not algorithmic.

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

Implementation detail: when scrolling the playfield we shift attribute bytes row-by-row (using `MemMove` per row) instead of moving the whole attribute memory at once. Doing the move per row avoids transient "garbage" appearing in the right-most column due to overlapping memory regions during the shift.

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


[Download the game](https://juntelart.itch.io/flapper-boriel)
