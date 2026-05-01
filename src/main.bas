' Libraries
#include <putchars.bas>
#include <retrace.bas>
#include <memcopy.bas>
#include <clearbox.bas>

' Modules
#include "definitions.bas"
#include "functions.bas"
#include "spriteset.bas"
#include "input.bas"
#include "physics.bas"
#include "draw.bas"
#include "collision.bas"

' Screens of the game
#include "screens/playGame.bas"
#include "screens/menu.bas"
#include "screens/gameOver.bas"

Border 0: Paper 1: Ink 6: Cls

showMenuScreen()