
    *=$a800

    lda     #<dl
    sta     560
    lda     #>dl
    sta     561
    lda     #<dli
    sta     512
    lda     #>dli
    sta     513
    lda     #192
    sta     54286

    lda     #$b0
    sta     756

    ldy     #0
ru1
    lda     zs1, y
    sta     $b0 * 256 + 8, y
    iny
    cpy     #24
    bne     ru1

    ldy     #0
ru2
    lda     text, y
    sta     text + 40, y
    sta     text + 80, y
    sta     text + 120, y
    sta     text + 160, y
    iny
    cpy     #40
    bne     ru2


loop
    jmp loop

dl
    .byte   112, 112, 240, 196
    .word   text
    .byte   132, 132, 132, 132, 65
    .word   dl

dli
    pha
    tya
    pha

    ldy     #0
ru3
    lda     tab1, y
    sta     53270
    lda     tab2, y
    sta     53271
    lda     tab3, y
    sta     53272
    lda     tab4, y
    sta     53273

    sta     54282
    iny
    cpy     #8
    bne     ru3

    pla
    tay
    pla
    rti

tab1
    .byte   48, 50, 52, 54, 56, 58, 60, 62
tab2
    .byte   192, 194, 196, 198, 200, 202, 204, 206
tab3
    .byte   112, 114, 116, 118, 120, 122, 124, 126
tab4
    .byte   240, 242, 244, 246, 248, 250, 252, 254

zs1
    .byte   85, 85, 85, 85, 85, 85, 85, 85
    .byte   170, 170, 170, 170, 170, 170, 170, 170
    .byte   255, 255, 255, 255, 255, 255, 255, 255

text
    .sbyte  "!!!!!!!!########!!!!!!!!########"



