    run     start
    org     $4000

WSYNC       = $d40a
VCOUNT      = $d40b
COLPF2      = $d018
TMP         = $ce
DL          = $cc

start
    lda     $0230
    sta     DL
    lda     $0231
    sta     DL+1
    lda     #<dli
    sta     $0200
    lda     #>dli
    sta     $0201

    ldy     #3
    lda     (DL),y
    eor     #128
    sta     (DL),y
    ldy     #8
dlloop
    lda     (DL),y
    eor     #128
    sta     (DL),y
    iny
    cpy     #29
    bne     dlloop
    lda     #192
    sta     $d40e

main
    lda     #$ff
    sta     $02fc 
loop
    ldx     $02fc
    cpx     #$ff
    bne     exit
    jmp     loop
exit
    rts

dli
    pha
    lda     VCOUNT
    sta     WSYNC 
    sta     COLPF2
    pla
    rti 

