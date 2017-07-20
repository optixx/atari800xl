    run     start
    org     $a800
start
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
loop
    jmp     loop

dl
    .byte   112, 112, 240, 114 
    .word   text
    .byte   65
    .word   dl

dli 
    pha
    tya
    pha
    ldy     #0
row
    lda     0, y
    sta     54282
    sta     54276

    sta     53272 
    sta     53273 
    sta     53274 
    iny
    cpy     #254
    bne     row

    pla
    tay
    pla 
    rti 

tab1
    .byte    1, 1, 1, 0, 0, 0, 0
    
text    
    .byte   "     DLI TEXT DEMO 123"



    
