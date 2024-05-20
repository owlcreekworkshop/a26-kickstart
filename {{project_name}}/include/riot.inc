.ifndef __RIOT_INC__
__RIOT_INC__ = 1

; Read registers
SWCHA  := $0280
SWACNT := $0281
SWCHB  := $0282
SWBCNT := $0283
INTIM  := $0284
TIMINT := $0285

; Write registers
TIM1T  := $0294
TIM8T  := $0295
TIM64T := $0296
T1024T := $0297

.endif