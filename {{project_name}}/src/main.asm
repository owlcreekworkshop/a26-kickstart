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
    ldx #0                      ; Set X to 0
    txa                         ; Set A to 0
:
    dex                         ; Decrement loop counter (Wraps to #$FF)
    txs                         ; Update stack pointer
    pha                         ; Zero out value at stack address
    bne :-                      ; Loop until X is 0

    lda #2                      ; Enable VBLANK
    sta VBLANK

;
; Initialize program.
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
; Game Logic
;

    ; **** Logic ***

;
; VBLANK
;

vblank_wait:
    sta WSYNC
    lda INTIM
    bne vblank_wait

    lda #0
    sta VBLANK

;
; Scanlines (NTSC)
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
; Game Logic
;

    ; **** Logic ***

overscan_wait:
    sta WSYNC
    lda INTIM
    bne overscan_wait

    jmp frame_start

.segment "VECTORS"
    .word reset
    .word reset
    .word reset