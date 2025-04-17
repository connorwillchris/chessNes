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
world:
    .res 2

.segment "STARTUP"
RESET:
    SEI ; Disables all interrupts
    CLD ; disable decimal mode

    ; Disable sound IRQ
    ldx #$40
    stx $4017

    ; Initialize the stack register
    ldx #$FF
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
   
; wait for vblank
vblank2:
    bit $2002
    bpl vblank2

    lda #$02
    sta $4014
    

    ; $3F00
    lda #$3F
    sta $2006
    lda #$00
    sta $2006

    ldx #$00

load_palettes:
    lda palette_data, x
    sta $2007 ; $3F00, $3F01, $3F02 => $3F1F
    inx 
    cpx #$20
    bne load_palettes   

    ldx #$00

load_sprites:
	lda sprite_data, x
	sta $0200, x
	inx 
	cpx #$08
	bne load_sprites

; Clear the nametables- this isn't necessary in most emulators unless
; you turn on random memory power-on mode, but on real hardware
; not doing this means that the background / nametable will have
; random garbage on screen. This clears out nametables starting at
; $2000 and continuing on to $2400 (which is fine because we have
; vertical mirroring on. If we used horizontal, we'd have to do
; this for $2000 and $2800)
    ldx #$00
    ldy #$00
    lda $2002
    lda #$20
    sta $2006
    lda #$00
    sta $2006
clear_nametable:
    sta $2007
    inx 
    bne clear_nametable
    iny 
    cpy #$08
    bne clear_nametable
    
; Enable interrupts
    cli 
    lda #%10010000 ; enable NMI change background to use second chr set of tiles ($1000)
    sta $2000
    ; Enabling sprites and background for left-most 8 pixels
    ; Enable sprites and background
    lda #%00011110 ; enable the first two bits
    sta $2001

mainloop:
    jmp mainloop

NMI:
	lda #$02 ; copy sprite data from $0200 => PPU memory for display
	sta $4014
	rti 

palette_data:
;	Background Palette
	.byte $0f, $00, $00, $00
	.byte $0f, $00, $00, $00
	.byte $0f, $00, $00, $00
	.byte $0f, $00, $00, $00

;	Sprite Palette
  	.byte $0f, $20, $00, $00
  	.byte $0f, $00, $00, $00
  	.byte $0f, $00, $00, $00
 	.byte $0f, $00, $00, $00

sprite_data:
  	.byte $08, $01, $00, $00
  	.byte $10, $02, $00, $00

.segment "CHARS"

.byte $00, $00, $00, $00, $00, $00, $00, $00 ; 1 * 8x8 sprite
.byte $00, $00, $00, $00, $00, $00, $00, $00 ; ...

; 	bishop TOP (1)
	.byte %00010000
	.byte %00110100
	.byte %00110100
	.byte %00011000
	.byte %00111100
	.byte %00000000
	.byte %00011000
	.byte %00011000

.byte $00, $00, $00, $00, $00, $00, $00, $00 ; 1 * 8x8 sprite

;	bishop BOTTOM (2)
	.byte %00111100
	.byte %00000000
	.byte %11111111
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000

.byte $00, $00, $00, $00, $00, $00, $00, $00 ; 1 * 8x8 sprite
