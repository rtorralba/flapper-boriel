# Devlog — mejoras respecto a la versión anterior

## Español

Resumen

Esta entrada documenta los cambios introducidos en la rama `feat-4px-scroll-and-sprite-animation` respecto a la versión anterior del port. Las mejoras principales son:

- Scroll fino a 4px por frame en lugar del desplazamiento por columnas de atributos.
- Animación del sprite del pájaro (frames alternos) para aportar fluidez.
- Ajustes en el pipeline de render para evitar tearing: cálculo previo en `screenBuffer` y un único `memcopy` al final del frame.
- Revisión de colisión para funcionar correctamente con el scroll de 4px.

Motivación

La versión anterior usaba un desplazamiento coordinado a nivel de atributos (columnas de 8×8 caracteres / cajas de atributo), lo que limitaba el movimiento horizontal a incrementos grandes y hacía la animación menos fluida. Pasar a 4px por frame mejora la sensación de movimiento sin cambiar la geometría del juego.

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

  - El sprite del pájaro ahora tiene 2 (o más) frames en `src/spriteset.bas`. El juego alterna el índice del frame cada N frames (por ejemplo, cada 6 frames) para dar sensación de aleteo.

  - Pseudocódigo de animación:

  ```bas
  birdAnimTimer = birdAnimTimer + 1
  If birdAnimTimer >= 6 Then
    birdAnimTimer = 0
    birdFrame = (birdFrame + 1) Mod 2
  End If

  putChars(birdX, Int(birdYPos), 2, 2, @spriteFrames(birdFrame))
  ```


Compatibilidad con colisión y lógica existente

La colisión requirió pequeños ajustes porque ahora el pájaro puede estar parcialmente dentro de una columna de atributos durante varios frames (al alternar los atributos). Para mantener comportamiento consistente:

- La comprobación de colisión se hace en coordenadas de juego (geométricas): se calcula si el rectángulo del pájaro intersecta la geometría de una tubería, no solo leyendo atributos redondeados a la columna. Esto evita falsos positivos/negativos cuando el scroll está en fase intermedia.

- En práctica, se sigue usando la optimización de comprobar solo la tubería frontal (la que puede estar en contacto), pero usando posiciones en píxeles y las anchuras/gaps en píxeles.

Rendimiento y timing

- Calcular el `screenBuffer` completo y realizar un único `memcopy` en el `waitretrace` sigue siendo la estrategia; el cálculo adicional por el scroll a 4px y la animación del sprite es ligero comparado con el coste de múltiples escrituras a la RAM de atributos.

- Para mantener la tasa de frames, las operaciones costosas (actualizar posiciones, decidir spawns, preparar columnas) se hacen antes del `waitretrace`; el `memcopy` es la única escritura de pantalla que se hace durante la ventana de retrace.

Qué cambiará para los usuarios

- Movimiento horizontal más suave: el mundo se desplaza 4px por frame.
- El pájaro aleteará con un sprite animado.
- Colisiones más precisas gracias a la comprobación geométrica en píxeles.

Enlaces

- Código de esta mejora (rama): [feat/4px-scroll-and-sprite-animation](https://github.com/rtorralba/flapper-boriel/tree/feat/4px-scroll-and-sprite-animation)

---

## English

Summary

This devlog describes the changes in branch `feat-4px-scroll-and-sprite-animation` vs the previous version. Main improvements:

- 4px-per-frame smooth scroll instead of attribute-column shifts.
- Sprite animation for the bird (frame alternation).
- Render pipeline adjusted to compute into `screenBuffer` and perform a single `memcopy` per frame to avoid tearing.
- Collision checks adapted to work correctly with sub-column pixel scrolling.

Motivation

Previous builds moved the world at attribute-sized steps, which made horizontal motion choppy. A 4px-per-frame scroll yields smoother movement without changing gameplay geometry.

Technical implementation (summary)



- 4px scroll:

  - Smooth horizontal scroll is achieved by alternating the attributes of both the pipe columns and the floor between normal values (`ATTR_PIPE`, `ATTR_SKY`, etc.) and special values (`ATTR_FIRST_HALF` and `ATTR_LAST_HALF`) on even and odd frames (`worldCol Mod 2`).
  - The `halfTile` pixel pattern (left half of the character ON) means that, combined with these attributes, each character is visually split: left half with one ink/paper color, right half with another.
  - This creates the illusion that both pipes and floor move 4px per frame, even though attribute memory remains 32 columns wide. There is no logical 64-column buffer or true pixel offset.
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

  - The bird sprite has 2 frames in `src/spriteset.bas`. The engine toggles the frame index every N frames (e.g., 6) to animate flapping.

  - Pseudocode:

  ```bas
  birdAnimTimer = birdAnimTimer + 1
  If birdAnimTimer >= 6 Then
    birdAnimTimer = 0
    birdFrame = (birdFrame + 1) Mod 2
  End If

  putChars(birdX, Int(birdYPos), 2, 2, @spriteFrames(birdFrame))
  ```


Collision and compatibility

Collision required small adjustments because now the bird can be partially inside a pipe attribute column for several frames (due to attribute alternation). To keep behavior consistent:

- Collision is checked using game (geometric) coordinates: it computes if the bird's rectangle intersects the pipe geometry, not just by reading attributes rounded to columns. This avoids false positives/negatives when the scroll is in an intermediate phase.

- In practice, the optimization of checking only the front pipe (the one that can be in contact) is still used, but using pixel positions and pipe widths/gaps.

Performance and timing

Heavy computation remains before `waitretrace`. The additional work for pixel-scrolling and sprite frames is modest; the single `memcopy` per frame preserves tear-free rendering.

User-visible changes

- Smoother horizontal scroll (4px steps).
- Animated bird sprite.
- More precise collisions.

Links

- Branch with the code for this devlog: [feat/4px-scroll-and-sprite-animation](https://github.com/rtorralba/flapper-boriel/tree/feat/4px-scroll-and-sprite-animation)
