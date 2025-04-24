;nametable_clear:
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