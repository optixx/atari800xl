
    *=$a800
; clear player data


; set dli
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

    
    ldy     #<vbi
    ldx     #>vbi
    lda     #6
    jsr     58460

    lda     #$b0
    sta     54279 
    lda     #1
    sta     53256
    lda     #62
    sta     559
    lda     #3
    sta     53277 

ikl 
    ldx     #0
ikl2
    inc     colo, x
    inx 
    cpx     #2
    beq     ikl
    lda     #1
    sta     540
ghq
    lda     540
    cmp     #0
    bne     ghq 
    jmp     ikl2


dl
    .byte   112, 112, 112, 240, 112, 122
    .byte   112, 112, 112, 65
    .word   dl


dli
    pha
pos1
    lda     #100
    sta     53248
ppoo1
    lda     #0
    sta     53266
    sta     54282 
    pla 
    rti 

vbi
    ldy     merk
    lda     tab1, y
    sta     pos1 + 1
    lda     colo, y
    sta     ppoo1 + 1

    lda     tab2, y
    clc
    sbc     #31
    asl
    asl
    asl
    tay
    ldx     #0
qw1
    lda     225 * 256, y
    sta     $b0 * 256 + 1024 + 100, x
    iny
    inx 
    cpx     #8
    bne     qw1
    inc     merk
    lda     merk
    cmp     #4
    bne     jk1
    lda     #0
    sta     merk

jk1
    jmp     58463

tab1
    .byte   80, 100, 120, 140, 180
colo 
    .byte   0, 85, 170, 230, 88 

merk 
    .byte   0

tab2
    .sbyte "ATARI"


