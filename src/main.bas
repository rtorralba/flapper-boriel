#include <putchars.bas>
#include <retrace.bas>
#include <keys.bas>
#include <memcopy.bas>
#include "definitions.bas"
#include "spriteset.bas"
#include "input.bas"
#include "physics.bas"
#include "draw.bas"
#include "collision.bas"
#include "sound.bas"
#include "play.bas"

Border 0: Paper 1: Ink 7: Cls

drawHUD()
drawStartScreen()

play()