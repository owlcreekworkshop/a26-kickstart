.include "tia.inc"
.include "riot.inc"

.segment "CODE"

reset:
;
; Initialize CPU
;
    sei                         ; Disable interrupts.
    cld                         ; Disable BCD arithmetic.

;
; Clear RAM, TIA registers, and initialize stack pointer.
;
    ldx #0                      ; Setup clear loop counter
    txa                         ; Set A to 0, value to use for initialization
clear:
    dex                         ; Update loop counter
    txs                         ; Reset stack pointer
    pha                         ; Zero out value at stack address
    bne clear                   ; Stay in clear loop until X is 0

    lda #2                      ; Enable VBLANK
    sta VBLANK

    ;
    ; Global program initialization can be performed here.
    ;

;
; Main Loop
;
frame_start:
    sta WSYNC                   ; Wait for start of next scanline
    lda #2                      ; Enable VSYNC
    sta VSYNC

    sta WSYNC                   ; First line of VSYNC
    lda #47                     ; Setup timer for VSYNC and VBLANK duration
    sta TIM64T                  ; 40 scanlines ((3 + 37) * 76) / 64 = ~47

    sta WSYNC                   ; Second line of VSYNC
    lda #0                      ; Prepare to disable VSYNC

    sta WSYNC                   ; Third line of VSYNC
    sta VSYNC                   ; Disable VSYNC

;
; VBLANK Logic Area
;

    ;
    ; 37 scanlines for VBLANK allowing for ~2,812 machine cycles of work.
    ;

;
; VBLANK
;

vblank_wait:
    sta WSYNC                   ; Wait for start of next scanline
    lda INTIM                   ; Has timer elapsed?
    bne vblank_wait             ; Stay in vblank_wait loop until the timer has elapsed.

    lda #0                      ; Disable VBLANK
    sta VBLANK

{% if video_format == "NTSC" -%}
;
; Screen Rendering Kernel (NTSC, 192 scanlines)
;
    ldx #192                    ; Setup kernel loop for 192 scanlines
{%- else -%}
;
; Screen Rendering Kernel (PAL, 242 scanlines)
;
    ldx #242                    ; Setup kernel loop for 242 scanlines
{%- endif %}
kernel:
    sta WSYNC                   ; Wait for start of next scanline
    stx COLUBK                  ; Set background color
    dex                         ; Update loop counter
    bne kernel                  ; Stay in kernel loop until all scanlines have been drawn

;
; Overscan
;
    lda #2                      ; Enable VBLANK
    sta VBLANK

    lda #35                     ; Setup timer for overscan duration
    sta TIM64T                  ; 29 scanlines ((30 * 76) / 64) = ~35

;
; Overscan Logic Area
;

    ;
    ; 29 scanlines for overscan allowing for ~2,204 machine cycles of work.
    ;
    ; NOTE: We sacrified one of the 30 scanlines during overscan to the start 
    ; of the VSYNC signal to allow for a more steady frame.
    ;

overscan_wait:
    sta WSYNC                   ; Wait for start of next scanline
    lda INTIM                   ; Has timer elapsed?
    bne overscan_wait           ; Stay in overscan_wait loop until timer has elapsed.

    jmp frame_start             ; Start the next frame.

.segment "VECTORS"
    .word reset
    .word reset
    .word reset

.segment "RODATA"

    ;
    ; Reserve ROM space for data.
    ;
