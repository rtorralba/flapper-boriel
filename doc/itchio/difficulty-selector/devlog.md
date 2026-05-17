# Selector de velocidad

<iframe width="560" height="315" src="https://www.youtube.com/embed/oNjfoLYykuA?si=UcJbAClxtjJPBlup" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

Español
-------

Cambios principales
------------------
- Añadida la variable global `speed` (0 = NORMAL, 1 = BORIEL) para controlar el ritmo del juego.
- Tecla `S` alterna el modo de velocidad (`NORMAL` <-> `BORIEL`) tanto en el menú como durante la partida.
- La rutina de espera de inicio se renombró a `waitKeyboardForOption` (antes `waitAnyKey`) y ahora ignora `S` para permitir cambiar la velocidad sin iniciar la partida.
- `screenSync()` respeta `speed`: en `NORMAL` ejecuta `waitretrace`, en `BORIEL` lo omite (modo más rápido).
- El menú muestra `Speed: NORMAL` o `Speed: BORIEL` según la selección.

Archivos modificados
--------------------
- `src/definitions.bas` — nueva variable `speed`.
- `src/input.bas` — lectura de teclado: toggle de `speed`, `waitKeyboardForOption`.
- `src/screens/menu.bas` — indicador de velocidad en el menú.
- `src/screens/playGameModule.bas` — `screenSync()` condicionado por `speed`.

Cómo probar
-----------
1. Abrir el menú principal; pulsar `S` para alternar el modo (se mostrará `Speed: NORMAL`/`Speed: BORIEL`).
2. Pulsar cualquier otra tecla para comenzar la partida.
3. Durante la partida, pulsar `S` para alternar el modo en caliente y comparar la diferencia de ritmo (BORIEL omite `waitretrace`).

Enlaces
-------
- Rama con los cambios: [https://github.com/rtorralba/flapper-boriel/tree/feat/difficulty-selector](https://github.com/rtorralba/flapper-boriel/tree/feat/difficulty-selector)

English
-------
Main changes
------------
- Added global variable `speed` (0 = NORMAL, 1 = BORIEL) to control game tempo.
- `S` key toggles speed mode (`NORMAL` <-> `BORIEL`) in menu and during gameplay.
- Startup wait routine renamed to `waitKeyboardForOption` (previously `waitAnyKey`) and now ignores `S` so speed can be changed without starting the game.
- `screenSync()` respects `speed`: in `NORMAL` it executes `waitretrace`, in `BORIEL` it skips it (faster mode).
- Menu displays `Speed: NORMAL` or `Speed: BORIEL` according to selection.

Modified files
--------------
- `src/definitions.bas` — new `speed` variable.
- `src/input.bas` — keyboard handling: toggle `speed`, `waitKeyboardForOption`.
- `src/screens/menu.bas` — menu speed indicator.
- `src/screens/playGameModule.bas` — `screenSync()` conditioned by `speed`.

How to test
-----------
1. Open the main menu; press `S` to toggle mode (the menu shows `Speed: NORMAL`/`Speed: BORIEL`).
2. Press any other key to start the game.
3. During gameplay, press `S` to toggle mode and compare the tempo difference (BORIEL omits `waitretrace`).

Links
-----
- Branch with changes: [https://github.com/rtorralba/flapper-boriel/tree/feat/difficulty-selector](https://github.com/rtorralba/flapper-boriel/tree/feat/difficulty-selector)
