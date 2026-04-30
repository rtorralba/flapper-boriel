' Libraries
#include <putchars.bas>
#include <retrace.bas>
#include <keys.bas>
#include <memcopy.bas>

' Modules
#include "definitions.bas"
#include "functions.bas"
#include "spriteset.bas"
#include "input.bas"
#include "physics.bas"
#include "draw.bas"
#include "collision.bas"

' Screens of the game
#include "screens/menu.bas"
#include "screens/playGame.bas"
#include "screens/gameOver.bas"

Border 0: Paper 1: Ink 6: Cls

showMenuScreen()