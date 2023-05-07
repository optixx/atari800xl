; Written in 2019 by Rob McMullen, https://playermissile.com/dli_tutorial/
; Copyright and related rights waived via CC0: https://creativecommons.org/publicdomain/zero/1.0/
; common routines, no origin here so they can be included wherever needed


;
; Load DLI address and set NMIEN. High byte of DLI in X, low byte in Y
;
init_dli
        ; load display list interrupt address
        sty VDSLST
        stx VDSLST+1

        ; activate display list interrupt
        lda #NMIEN_VBI | NMIEN_DLI
        sta NMIEN
        rts
