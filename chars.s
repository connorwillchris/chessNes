;	BISHOP TOP

;	HIGH BYTE OF DATA
	.byte %00010000
	.byte %00110100
	.byte %00110100
	.byte %00011000
	.byte %00111100
	.byte %00000000
	.byte %00011000
	.byte %00011000

; LOW BYTE PLACEHOLDER
.byte $00, $00, $00, $00, $00, $00, $00, $00

;	BISHOP BOTTOM (2)
	.byte %00111100
	.byte %00000000
	.byte %11111111
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000

; LOW BYTE PLACEHOLDER
.byte $00, $00, $00, $00, $00, $00, $00, $00

;   SELECTION SPRITE (3)
    .byte %11111110
    .byte %10000000
    .byte %10000000
    .byte %10000000
    .byte %10000000
    .byte %10000000
    .byte %10000000
    .byte %00000000

.byte $00, $00, $00, $00, $00, $00, $00, $00
