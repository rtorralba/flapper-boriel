#include <putchars.bas>
#include <memorybank.bas>
#include <scrbuffer.bas>
#include "definitions.bas"
#include "shadowScreen.bas"
#include "generated/spriteset.bas"
#include "draw.bas"
#include "play.bas"

Border 0
Paper 1
Ink 7
Cls
drawHUD()
drawStartScreen()

play()