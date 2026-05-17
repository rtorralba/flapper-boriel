# Devlog — mejoras respecto a la versión anterior

## Español

Resumen

En esta entrada cuento qué ha cambiado en la rama `feat-4px-scroll-and-sprite-animation` respecto a la versión anterior del port. En resumen:

- Scroll fino a 4px por frame en lugar del desplazamiento al carácter.
- Animación del sprite del pájaro (frames alternos) para aportar fluidez.
- Ajustes en el pipeline de render para evitar tearing: cálculo previo en `screenBuffer` y un único `memcopy` al final del frame.
- Revisión de colisión para funcionar correctamente con el scroll de 4px.

<div style="text-align: center">
<iframe width="560" height="315" src="https://www.youtube.com/embed/rsFkA2AfYEk?si=TVgGOsP_G5FXmACH" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>
</div>



Motivación

El problema con la versión anterior era que el desplazamiento iba a saltos de un carácter entero (columnas de 8×8 píxeles), lo que hacía el movimiento horizontal bastante brusco. Quería algo más suave sin tocar la geometría del juego, y pasar a 4px por frame fue la solución.

Implementación técnica (resumen)

- Scroll a 4px:

  - El scroll horizontal suave se consigue alternando los atributos tanto de las columnas de tubería como del suelo entre valores normales (`ATTR_PIPE`, `ATTR_SKY`, etc.) y valores especiales (`ATTR_FIRST_HALF` y `ATTR_LAST_HALF`) en frames pares e impares (`worldCol Mod 2`).
  - El patrón de píxeles `halfTile` (mitad izquierda del carácter encendida) permite que, al combinarse con estos atributos, cada carácter se pinte visualmente partido: la mitad izquierda con un color (ink/paper) y la derecha con otro.
  - Así, tanto las tuberías como el suelo parecen avanzar 4px cada frame, aunque la memoria de atributos sigue siendo de 32 columnas. No se duplica la resolución lógica ni se hace un desplazamiento por píxel real.
  - Fragmento clave del código (`src/draw.bas`):

```bas
  If worldCol Mod 2 = 1 Then
    attrFront = ATTR_FIRST_HALF
    attrBack = ATTR_LAST_HALF
  Else
    attrFront = ATTR_PIPE
    attrBack = ATTR_SKY
  End If
  ...
  bufferPipeColumn(leadingCol, gap, attrFront)
  bufferPipeColumn(trailingCol, gap, attrBack)
```

- Animación del sprite:

  - El sprite del pájaro ahora tiene 3 frames en `src/spriteset.bas`. El juego alterna el índice del frame cada N frames (por ejemplo, cada 6 frames) para dar sensación de aleteo.

  - Código de animación:

```bas
  Sub drawBird()
      ' Calculate yo-yo animation frame (0, 1, 2, 1) changing every 2 ticks
      Dim animIdx As Ubyte = (worldCol / 2) Mod 4
      If animIdx = 3 Then animIdx = 1
      
      ' Draw pixels based on animation frame
      If animIdx = 0 Then
          putChars(birdX, Int(birdYPos), 2, 2, @sprite0(0))
      ElseIf animIdx = 1 Then
          putChars(birdX, Int(birdYPos), 2, 2, @sprite1(0))
      Else
          putChars(birdX, Int(birdYPos), 2, 2, @sprite2(0))
      End If
      
      ' Paint bird with Yellow Ink (6) and Blue Paper (1) -> 14
      paint(birdX, Int(birdYPos), 2, 2, 14)
  End Sub
```

Compatibilidad con colisión y lógica existente

Al introducir el scroll a 4px, el pájaro puede quedarse durante varios frames a caballo entre dos columnas de atributos, lo que rompía las colisiones. Para arreglarlo sin complicar demasiado el código:

- La comprobación de colisión ahora usa coordenadas de juego (geométricas): se calcula si el rectángulo del pájaro intersecta la geometría de una tubería, en lugar de leer atributos redondeados a la columna. Así se evitan falsos positivos/negativos en la fase intermedia del scroll.

- Seguimos comprobando solo la tubería frontal (la que puede estar en contacto), pero con posiciones y anchuras/gaps en píxeles.

Rendimiento y timing

Me preocupaba que estos cambios afectasen la tasa de frames, pero por suerte no ha sido así. El coste extra del scroll a 4px y la animación del sprite es mínimo comparado con hacer múltiples escrituras directas a la RAM de atributos. La estrategia sigue siendo la misma: calcular el `screenBuffer` completo antes del `waitretrace` y hacer un único `memcopy` durante la ventana de retrace para evitar el tearing.

Qué notarán los jugadores

- El mundo se mueve más suave: 4px por frame en lugar de saltos de carácter.
- El pájaro aletea con un sprite animado.
- Las colisiones son más precisas gracias a la comprobación geométrica en píxeles.

Enlaces

- Código de esta mejora (rama): [feat/4px-scroll-and-sprite-animation](https://github.com/rtorralba/flapper-boriel/tree/feat/4px-scroll-and-sprite-animation)

---

## English

Summary

In this post I go over what changed in the `feat-4px-scroll-and-sprite-animation` branch compared to the previous port version. The short version:

- Fine horizontal scroll at 4px per frame instead of character-based shifts.
- Bird sprite animation (alternating frames) for smoother motion.
- Render pipeline adjustments to avoid tearing: pre-calculation in `screenBuffer` and a single `memcopy` at the end of the frame.
- Collision logic revised to work correctly with 4px scrolling.

<div style="text-align: center">
<iframe width="560" height="315" src="https://www.youtube.com/embed/rsFkA2AfYEk?si=TVgGOsP_G5FXmACH" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>
</div>



Motivation

The issue with the previous version was that the world moved in full character steps (8×8 pixel columns), which made horizontal motion feel pretty jerky. I wanted something smoother without touching the game's geometry — moving to 4px per frame did the trick.

Technical implementation (summary)

- 4px scroll:

  - Smooth horizontal scrolling is achieved by alternating the attributes of both the pipe columns and the floor between normal values (`ATTR_PIPE`, `ATTR_SKY`, etc.) and special values (`ATTR_FIRST_HALF` and `ATTR_LAST_HALF`) on even and odd frames (`worldCol Mod 2`).
  - The `halfTile` pixel pattern (left half of the character ON) allows each character to be visually split: the left half with one color (ink/paper) and the right half with another.
  - This way, both pipes and floor appear to move 4px per frame, even though the attribute memory remains 32 columns wide. There is no logical resolution doubling or true per-pixel shift.
  - Key code fragment (`src/draw.bas`):

```bas
  If worldCol Mod 2 = 1 Then
    attrFront = ATTR_FIRST_HALF
    attrBack = ATTR_LAST_HALF
  Else
    attrFront = ATTR_PIPE
    attrBack = ATTR_SKY
  End If
  ...
  bufferPipeColumn(leadingCol, gap, attrFront)
  bufferPipeColumn(trailingCol, gap, attrBack)
```

- Sprite animation:

  - The bird sprite now has 3 frames in `src/spriteset.bas`. The game alternates the frame index every N frames (e.g., every 6 frames) to create a flapping effect.

  - Animation code:

```bas
  Sub drawBird()
      ' Calculate yo-yo animation frame (0, 1, 2, 1) changing every 2 ticks
      Dim animIdx As Ubyte = (worldCol / 2) Mod 4
      If animIdx = 3 Then animIdx = 1
      
      ' Draw pixels based on animation frame
      If animIdx = 0 Then
          putChars(birdX, Int(birdYPos), 2, 2, @sprite0(0))
      ElseIf animIdx = 1 Then
          putChars(birdX, Int(birdYPos), 2, 2, @sprite1(0))
      Else
          putChars(birdX, Int(birdYPos), 2, 2, @sprite2(0))
      End If
      
      ' Paint bird with Yellow Ink (6) and Blue Paper (1) -> 14
      paint(birdX, Int(birdYPos), 2, 2, 14)
  End Sub
```


Collision and logic compatibility

With sub-character scrolling, the bird can straddle two attribute columns for several frames, which broke collisions. To fix it without overcomplicating the code:

- Collision checks now use game (geometric) coordinates: it calculates whether the bird's rectangle intersects the pipe geometry, rather than reading attributes rounded to columns. This avoids false positives/negatives during intermediate scroll phases.

- We still only check the front pipe (the one that can actually be in contact), just using pixel positions and widths/gaps instead of column indices.

Performance and timing

I was a bit worried these changes would tank the frame rate, but it turned out fine. The extra work for 4px scrolling and sprite animation is negligible compared to hammering the attribute RAM with multiple writes. The strategy stays the same: compute the full `screenBuffer` before `waitretrace`, then do a single `memcopy` during the retrace window to keep things tear-free.

What players will notice

- The world moves much smoother: 4px steps instead of full character jumps.
- The bird now flaps with an animated sprite.
- Collisions feel more precise thanks to the pixel-based geometric checks.

Links

- Code for this improvement (branch): [feat/4px-scroll-and-sprite-animation](https://github.com/rtorralba/flapper-boriel/tree/feat/4px-scroll-and-sprite-animation)
