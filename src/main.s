; vim: set syntax=asm_ca65:
.segment "HEADER"
	.byte "NES"
    .byte $1a
	.byte $02 ; 2 * 16KB PRG ROM
	.byte $01 ; 1 * 8KB CHR ROM
	.byte %00000001 ; mapper and mirroring
	.byte $00
	.byte $00
	.byte $00
	.byte $00
	.byte $00, $00, $00, $00, $00 ; filler bytes

.segment "VECTORS"
    .word NMI
    .word RESET
	.word 0

.segment "ZEROPAGE"
ptr_world:
    .res 2

.segment "STARTUP"
RESET:
    sei ; Disables all interrupts
    cld ; disable decimal mode
    ; Disable sound IRQ
    ldx #$40
    stx $4017
    ; Initialize the stack register
;   ldx #$FF
    txs
    inx ; #$FF + 1 => #$00
    ; Zero out the PPU registers
    stx $2000
    stx $2001
    stx $4010

vblank1:
    bit $2002
	bpl vblank1
    txa

clearmem:
    sta $0000, x ; $0000 => $00FF
    sta $0100, x ; $0100 => $01FF
;	IGNORE $0200, RESERVE IT FOR SPRITES
    sta $0300, x
    sta $0400, x
    sta $0500, x
    sta $0600, x
    sta $0700, x
    lda #$FF
    sta $0200, x ; $0200 => $02FF
    lda #$00
    inx
    bne clearmem

vblank2:
    bit $2002
    bpl vblank2

;   SET SPRITE RANGE
    lda #$02
    sta $4014
    ;nop ; must wait a few cycles
    lda #$3F
    sta $2006
    lda #$00
    sta $2006
;   INITIALIZE NEXT LOOP
    ldx #$00
load_palettes:
    lda palette_data, x
    sta $2007 ; $3F00, $3F01, $3F02 => $3F1F
    inx
    cpx #$20 ; 32 bytes of data
    bne load_palettes
;	LOAD THE ADDRESS OF THE WORLD
    lda #<world_data
    sta ptr_world
    lda #>world_data
    sta ptr_world + 1
;   setup address in PPU for nametable data
    ldx #$00
    ldy #$00
    lda $2002
    lda #$20
    sta $2006
    lda #$00
    sta $2006

load_world:
    lda (ptr_world), y
    sta $2007
    iny
    cpx #$03
    bne @loop1
    cpy #$c0
    beq @done_loading_world
@loop1:
    cpy #$00
    bne load_world
    inx
    inc ptr_world + 1 ; increment the world variable, adding 256 to the address essentially
    jmp load_world
@done_loading_world:
;   initialize next loop
    ldx #$00
;set_attributes:
;   lda #$55
;   sta $2007
;   inx
;   cpx #$40 ; 64 in decimal
;   bne set_attributes
;   END LOOP
;   ldx #$00
;   lda #$00

; Clear the nametables- this isn't necessary in most emulators unless
; you turn on random memory power-on mode, but on real hardware
; not doing this means that the background / nametable will have
; random garbage on screen. This clears out nametables starting at
; $2000 and continuing on to $2400 (which is fine because we have
; vertical mirroring on. If we used horizontal, we'd have to do
; this for $2000 and $2800)
;  .include "nametable_clr.s"

;   Enable interrupts
    cli
    lda #%10010000 ; enable NMI change background to use second chr set of tiles ($1000)
    sta $2000
;   Enabling sprites and background for left-most 8 pixels
;   Enable sprites and background
    lda #%00011110 ; enable the first two bits
    sta $2001

mainloop:
;	DO CONTROLLERS
;	jsr controllers

;   INFINITE LOOP
    jmp mainloop

NMI:
	lda #$02 ; copy sprite data from $0200 => PPU memory for display
	sta $4014
	rti
;
; DATA
;

palette_data:
;	Background Palette
;   .byte $0f, $00, $10, $30
;   .byte $0f, $0c, $21, $32
;   .byte $0f, $05, $16, $27
	.incbin "../bin/palettes.pal"

sprite_data:

world_data:
	.include "../world.s"

.segment "CHARS"
    .incbin "../bin/master.chr"
