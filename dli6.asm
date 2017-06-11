
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

main
    jmp main

dl
    .byte   112, 240, 112, 112, 112, 112
    .byte   65
    .word   dl


dli
    pha
    tya 
    pha 

    ldy     #0
tu1 
    lda     tab1, y
    sta     54282
    sta     53274
    iny 
    cpy     #33
    bne     tu1
    
    pla
    tay
    pla 
    rti 

tab1 
    .byte   112, 114, 116, 118, 120, 122, 124, 126
    .byte   126, 124, 122, 120, 118, 116, 114, 112
    .byte   62, 60, 58, 56, 54, 52, 50, 48, 0
