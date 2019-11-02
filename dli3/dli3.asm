    run     start
    org     $a800
start
    ldy     #0
    lda     #0
tu1 
    sta     176 * 256 + 1024, y
    iny
    cpy     #0
    bne     tu1 


; store player data
    ldy     #0
tu2
    lda     data1, y
    sta     180 * 256 + 50, y
    sta     180 * 256 + 140, y
    lda     data2, y
    sta     180 * 256 + 90, y
    sta     180 * 256 + 190, y
    iny
    cpy     #16
    bne     tu2

; set dli
    lda     #<dl1
    sta     560
    lda     #>dl1
    sta     561
    lda     #<dli1
    sta     512
    lda     #>dli1
    sta     513
    lda     #192
    sta     54286


main
    lda     #3
    sta     53277       ; GRACTL
    lda     #176 
    sta     54279       ; PMBASE
    lda     #62
    sta     559         ; SDMCTL
    rts

dli1
    pha
    lda     #180
    sta     53248       ; HPOSP0
    lda     #7 * 16 + 6 
    sta     53266       ; COLPM0

    sta     54282       ; WSYNC
    lda     #<dli2
    sta     512
    lda     #>dli2
    sta     513
    pla
    rti

dli2
    pha
    lda     #140
    sta     53248
    lda     #3 * 16 + 8
    sta     53266
    lda     #1
    sta     53256       ; SIZEP0
    sta     54282
    lda     #<dli3
    sta     512
    lda     #>dli3
    sta     513
    pla
    rti



dli3
    pha
    lda     #0
    sta     53256
    lda     #100
    sta     53248
    lda     #10 * 16 + 8
    sta     53266
    sta     54282

    lda     #<dli4
    sta     512
    lda     #>dli4
    sta     513
    pla
    rti


dli4
    pha
    lda     #60
    sta     53248
    lda     #4 * 16 + 6
    sta     53266
    sta     54282

    lda     #<dli1
    sta     512
    lda     #>dli1
    sta     513
    pla
    rti

dl1
    .byte   112, 112, 112, 112, 240
    .byte   112, 112, 112, 112, 240
    .byte   112, 112, 112, 112, 112, 240
    .byte   112, 112, 112, 112, 112, 240
    .byte   65 
    .word   dl1


data1
    .byte   36, 36, 126, 66, 90, 126, 24, 60, 126, 255, 189, 189, 36, 36, 102, 102
data2
    .byte   60, 126, 153, 90, 60, 24, 24, 24, 24, 24, 60, 126, 60, 24, 60, 126

