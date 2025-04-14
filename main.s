.segment "HEADER"
	.byte "NES", $1a
	.byte 2	; 2x 16KiB PRG code
	.byte 1	; 1x 8KiB  CHR data
	.byte $01, $00 ; mapper 0, vertical mirroring

.segment "VECTORS"
	.addr NMI
	.addr RESET
	.addr 0	; unused IRQ interrupt

;.import RESET

; NES linker config requires a startup section, even if it's empty
.segment "STARTUP"
.segment "CODE"

RESET:

	sei ; disable IRQs
	cld ; disable decimal mode
	ldx #$40
	stx $4017
	ldx #$ff ; disable APU frame IRQ
	txs ; set up stack
	inx ; now it's 0
	stx $2000 ; disable NMI
	stx $2001 ; disable rendering
	stx $4010 ; disable DMC IRQs

vblankwait1:
	bit $2002
	bpl vblankwait1

clearmem:
	lda #$00
	sta $0000, x
	sta $0100, x
	sta $0200, x
	sta $0300, x
	sta $0400, x
	sta $0500, x
	sta $0600, x
	sta $0700, x
	inx
	bne clearmem

vblankwait2:
	bit $2002
	bpl vblankwait2

main:
load_palettes:
	lda $2002
	lda #$3f
	sta $2006
	lda #$00
	sta $2006
	ldx #$00
@loop:
	lda palettes, x
	sta $2007
	inx
	cpx #$20
	bne @loop

enable_rendering:
	lda #%10000000 ; enable NMI
	sta $2000
	lda #%00010000 ; enable sprites
	sta $2001

main_loop:
	jmp main_loop

NMI:
	ldx #$00 ; set SPRITE RAM address to 0
	stx $2003
@loop:
	lda hello, x
	sta $2004
	inx
	cpx #28
	bne @loop
	rti

hello:
	.byte $00, $00, $00, $00, $00, $00, $00, $00
	.byte $6c, $00, $00, $6c
	.byte $6c, $01, $00, $76
	.byte $6c, $02, $00, $80
	.byte $6c, $02, $00, $8a
	.byte $6c, $03, $00, $94

palettes:
	; Background Palette
	.byte $0f, $00, $00, $00
	.byte $0f, $00, $00, $00
	.byte $0f, $00, $00, $00
	.byte $0f, $00, $00, $00

	; Sprite Palette
	.byte $0f, $20, $00, $00
	.byte $0f, $00, $00, $00
	.byte $0f, $00, $00, $00
	.byte $0f, $00, $00, $00

	.segment "CHARS"
	.byte %11000011	; H (00)
	.byte %11000011
	.byte %11000011
	.byte %11111111
	.byte %11111111
	.byte %11000011
	.byte %11000011
	.byte %11000011
	.byte $00, $00, $00, $00, $00, $00, $00, $00

	.byte %11111111	; E (01)
	.byte %11111111
	.byte %11000000
	.byte %11111100
	.byte %11111100
	.byte %11000000
	.byte %11111111
	.byte %11111111
	.byte $00, $00, $00, $00, $00, $00, $00, $00

	.byte %11000000	; L (02)
	.byte %11000000
	.byte %11000000
	.byte %11000000
	.byte %11000000
	.byte %11000000
	.byte %11111111
	.byte %11111111
	.byte $00, $00, $00, $00, $00, $00, $00, $00

	.byte %01111110	; O (03)
	.byte %11100111
	.byte %11000011
	.byte %11000011
	.byte %11000011
	.byte %11000011
	.byte %11100111
	.byte %01111110
	.byte $00, $00, $00, $00, $00, $00, $00, $00