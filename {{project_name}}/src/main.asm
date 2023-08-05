.include "atari2600.inc"

.segment "DATA"

;
; Data
;

.segment "CODE"

reset:
;
; Initialize CPU
;
    sei                         ; Disable interrupts.
    cld                         ; Disable BCD arithmetic.

;
; Clear RAM, TIA registers, and initialize stack pointer. 
; Courtesy: Andrew Davie
; See: https://forums.atariage.com/topic/27405-session-12-initialisation/
;
    ldx #0                      ; Set X to 0, loop counter
    txa                         ; Set A to 0, value to use for initialization
:
    dex                         ; Decrement loop counter
    txs                         ; Reset stack pointer
    pha                         ; Zero out value at stack address
    bne :-                      ; Loop until X is 0

    lda #2                      ; Enable VBLANK
    sta VBLANK


    ; 
    ; Global program initialization can be performed here.
    ;

;
; Main Loop
; 
frame_start:   
    lda #2                      ; Enable VSYNC
    sta VSYNC

    sta WSYNC                   ; First line of VSYNC
    lda #47                     ; Setup timer for VSYNC (3) + VBLANK (37)
    sta TIM64T                  ; 40 scanlines ((3 + 37) * 76) / 64
    
    sta WSYNC                   ; Second line of VSYNC
    sta WSYNC                   ; Third line of VSYNC

    lda #0                      ; Disable VSYNC
    sta VSYNC

;
; VBLANK Logic Area
;

    ; 37 scanlines for VBLANK allowing for ~2,812 machine cycles of work.

;
; VBLANK
;

vblank_wait:
    sta WSYNC                   ; Wait for scanline to finish.
    lda INTIM                   ; Check if timer has elapsed?
    bne vblank_wait             ; Stay in vblank_wait loop until the timer has elapsed.

    lda #0                      ; 
    sta VBLANK

;
; Screen Rendering Kernel (NTSC, 192 scanlines)
;
    ldx #192
:
    sta WSYNC
    stx COLUBK
    dex
    bne :-

;
; Overscan
;
    lda #2                      ; Enable VBLANK
    sta VBLANK

    lda #36                     ; Enable timer to go off in 30 scanlines.
    sta TIM64T                  ; 30 scanlines ((30 * 76) / 64)

;
; Overscan Logic Area
;

    ; 30 scanlines for overscan allowing for ~2,280 machine cycles of work.

overscan_wait:
    sta WSYNC
    lda INTIM
    bne overscan_wait

    jmp frame_start

.segment "VECTORS"
    .word reset
    .word reset
    .word reset