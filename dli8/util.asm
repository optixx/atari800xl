; Written in 2019 by Rob McMullen, https://playermissile.com/dli_tutorial/
; Copyright and related rights waived via CC0: https://creativecommons.org/publicdomain/zero/1.0/
; common routines, no origin here so they can be included wherever needed
; the screen memory is fixed at $8000, however.


;
; Create display list of 40x24 mode 4 lines
;
init_static_screen_mode4
        ; load display list & fill with test data
        lda #<dlist_static_mode4
        sta SDLSTL
        lda #>dlist_static_mode4
        sta SDLSTL+1
        jsr fillscreen_static
        rts

;
; Create display list of 40x24 mode 4 lines with a single DLI
;
init_dli_screen_mode4
        ; load display list & fill with test data
        lda #<dlist_static_mode4
        sta SDLSTL
        lda #>dlist_static_mode4
        sta SDLSTL+1
        lda #$84        ; turn on DLI bit for 2nd mode 4 line
        sta dlist_static_mode4_2nd_line
        jsr fillscreen_static
        rts

;
; Create display list of 40x24 mode 4 lines in 3 bands labeled A - C. Only 2
; DLIs are used in this case as the VBI is used to set players for the top
;
init_static_screen_mode4_3_bands
        ; load display list & fill with test data
        lda #<dlist_static_mode4
        sta SDLSTL
        lda #>dlist_static_mode4
        sta SDLSTL+1
        jsr fillscreen_static_3_bands
        lda #$84        ; turn on DLI bit on mode 4
        sta dlist_static_mode4_8th_line
        sta dlist_static_mode4_16th_line
        rts

;
; Create display list of 40x24 mode 4 lines in 6 bands labeled A - F
;
init_static_screen_mode4_6_bands
        ; load display list & fill with test data
        lda #<dlist_static_mode4
        sta SDLSTL
        lda #>dlist_static_mode4
        sta SDLSTL+1
        jsr fillscreen_static_6_bands
        lda #$f0        ; turn on DLI bit for 3rd $70 (8 blank lines)
        sta dlist_static_mode4 + 2
        lda #$84        ; turn on DLI bit for 5 mode lines, 4 lines apart
        sta dlist_static_mode4 + 8
        sta dlist_static_mode4 + 12
        sta dlist_static_mode4 + 16
        sta dlist_static_mode4 + 20
        sta dlist_static_mode4 + 24
        rts

;
; Create display list of 40x24 mode 4 lines in 12 bands labeled A - L
;
init_static_screen_mode4_12_bands
        ; load display list & fill with test data
        lda #<dlist_static_mode4
        sta SDLSTL
        lda #>dlist_static_mode4
        sta SDLSTL+1
        jsr fillscreen_static_12_bands
        lda #$f0        ; turn on DLI bit for 3rd $70 (8 blank lines)
        sta dlist_static_mode4 + 2
        lda #$84        ; turn on DLI bit for 5 mode lines, 2 lines apart
        sta dlist_static_mode4 + 6
        sta dlist_static_mode4 + 8
        sta dlist_static_mode4 + 10
        sta dlist_static_mode4 + 12
        sta dlist_static_mode4 + 14
        sta dlist_static_mode4 + 16
        sta dlist_static_mode4 + 18
        sta dlist_static_mode4 + 20
        sta dlist_static_mode4 + 22
        sta dlist_static_mode4 + 24
        sta dlist_static_mode4 + 26
        rts

;
; Create display list of 40x12 mode 5 lines in 12 bands labeled A - L
;
init_static_screen_mode5_12_bands
        ; load display list & fill with test data
        lda #<dlist_static_mode5
        sta SDLSTL
        lda #>dlist_static_mode5
        sta SDLSTL+1
        jsr fillscreen_static_24_bands
        lda #$f0        ; turn on DLI bit for 3rd $70 (8 blank lines)
        sta dlist_static_mode5 + 2
        lda #$c5        ; turn on DLI bit for 1st mode 5 line
        sta dlist_static_mode5_1st_line
        lda #$85        ; turn on DLI bit for every mode 5 line except the last
        sta dlist_static_mode5_2nd_line
        sta dlist_static_mode5_3rd_line
        sta dlist_static_mode5_4th_line
        sta dlist_static_mode5_5th_line
        sta dlist_static_mode5_6th_line
        sta dlist_static_mode5_7th_line
        sta dlist_static_mode5_8th_line
        sta dlist_static_mode5_9th_line
        sta dlist_static_mode5_10th_line
        sta dlist_static_mode5_11th_line
        rts

;
; Create display list of 40x12 mode 5 lines in 12 bands labeled A - L
;
init_static_screen_mode5_kernel
        ; load display list & fill with test data
        lda #<dlist_static_mode5
        sta SDLSTL
        lda #>dlist_static_mode5
        sta SDLSTL+1
        jsr fillscreen_static_24_bands
        lda #$f0        ; turn on DLI bit for 3rd $70 (8 blank lines)
        sta dlist_static_mode5 + 2
        rts

;
; table of band centers in PMG coords
;
center_pmg_y_6_bands
        .byte 40, 72, 104, 136, 168, 190

;
; Loop forever
;
forever
        jmp forever

;
; fill 24 lines of 40 bytes with test pattern
;
fillscreen_static
        ldy #0
?loop   tya
        sta $8000,y
        sta $8028,y
        sta $8050,y
        sta $8078,y
        sta $80a0,y
        sta $80c8,y
        sta $80f0,y
        sta $8118,y
        sta $8140,y
        sta $8168,y
        sta $8190,y
        sta $81b8,y
        sta $81e0,y
        sta $8208,y
        sta $8230,y
        sta $8258,y
        sta $8280,y
        sta $82a8,y
        sta $82d0,y
        sta $82f8,y
        sta $8320,y
        sta $8348,y
        sta $8370,y
        sta $8398,y
        iny
        cpy #40
        bcc ?loop
        rts

;
; fill 24 lines of 40 bytes with test pattern for 3 bands
;
fillscreen_static_3_bands
        ldy #0
?loop   lda #$41
        sta $8000,y
        sta $8028,y
        sta $8050,y
        sta $8078,y
        sta $80a0,y
        sta $80c8,y
        sta $80f0,y
        sta $8118,y
        lda #$a2
        sta $8140,y
        sta $8168,y
        sta $8190,y
        sta $81b8,y
        sta $81e0,y
        sta $8208,y
        sta $8230,y
        sta $8258,y
        lda #$43
        sta $8280,y
        sta $82a8,y
        sta $82d0,y
        sta $82f8,y
        sta $8320,y
        sta $8348,y
        sta $8370,y
        sta $8398,y
        iny
        cpy #40
        bcc ?loop
        rts

;
; fill 24 lines of 40 bytes with test pattern for 6 bands
;
fillscreen_static_6_bands
        ldy #0
?loop   lda #$41
        sta $8000,y
        sta $8028,y
        sta $8050,y
        sta $8078,y
        lda #$a2
        sta $80a0,y
        sta $80c8,y
        sta $80f0,y
        sta $8118,y
        lda #$43
        sta $8140,y
        sta $8168,y
        sta $8190,y
        sta $81b8,y
        lda #$a4
        sta $81e0,y
        sta $8208,y
        sta $8230,y
        sta $8258,y
        lda #$45
        sta $8280,y
        sta $82a8,y
        sta $82d0,y
        sta $82f8,y
        lda #$a6
        sta $8320,y
        sta $8348,y
        sta $8370,y
        sta $8398,y
        iny
        cpy #40
        bcc ?loop
        rts

;
; fill 24 lines of 40 bytes with test pattern for 12 bands
;
fillscreen_static_12_bands
        ldy #0
?loop   lda #$41
        sta $8000,y
        sta $8028,y
        lda #$a2
        sta $8050,y
        sta $8078,y
        lda #$43
        sta $80a0,y
        sta $80c8,y
        lda #$a4
        sta $80f0,y
        sta $8118,y
        lda #$45
        sta $8140,y
        sta $8168,y
        lda #$a6
        sta $8190,y
        sta $81b8,y
        lda #$47
        sta $81e0,y
        sta $8208,y
        lda #$a8
        sta $8230,y
        sta $8258,y
        lda #$49
        sta $8280,y
        sta $82a8,y
        lda #$aa
        sta $82d0,y
        sta $82f8,y
        lda #$4b
        sta $8320,y
        sta $8348,y
        lda #$ac
        sta $8370,y
        sta $8398,y
        iny
        cpy #40
        bcc ?loop
        rts

;
; fill 24 lines of 40 bytes with test pattern for 24 bands
;
fillscreen_static_24_bands
        ldy #0
?loop   lda #$41
        sta $8000,y
        lda #$a2
        sta $8028,y
        lda #$43
        sta $8050,y
        lda #$a4
        sta $8078,y
        lda #$45
        sta $80a0,y
        lda #$a6
        sta $80c8,y
        lda #$47
        sta $80f0,y
        lda #$a8
        sta $8118,y
        lda #$49
        sta $8140,y
        lda #$aa
        sta $8168,y
        lda #$4b
        sta $8190,y
        lda #$ac
        sta $81b8,y
        lda #$4d
        sta $81e0,y
        lda #$ae
        sta $8208,y
        lda #$4f
        sta $8230,y
        lda #$b0
        sta $8258,y
        lda #$51
        sta $8280,y
        lda #$b2
        sta $82a8,y
        lda #$53
        sta $82d0,y
        lda #$b4
        sta $82f8,y
        lda #$55
        sta $8320,y
        lda #$b6
        sta $8348,y
        lda #$57
        sta $8370,y
        lda #$b8
        sta $8398,y
        iny
        cpy #40
        bcc ?loop
        rts

; mode 4 standard display list
dlist_static_mode4
        .byte $70,$70,$70
dlist_static_mode4_1st_line
        .byte $44,$00,$80
dlist_static_mode4_2nd_line
        .byte 4,4
dlist_static_mode4_4th_line
        .byte 4,4
dlist_static_mode4_6th_line
        .byte 4,4
dlist_static_mode4_8th_line
        .byte 4,4
dlist_static_mode4_10th_line
        .byte 4,4
dlist_static_mode4_12th_line
        .byte 4,4
dlist_static_mode4_14th_line
        .byte 4,4
dlist_static_mode4_16th_line
        .byte 4,4
dlist_static_mode4_18th_line
        .byte 4,4
dlist_static_mode4_20th_line
        .byte 4,4
dlist_static_mode4_22nd_line
        .byte 4,4
dlist_static_mode4_24th_line
        .byte 4
        .byte $41,<dlist_static_mode4,>dlist_static_mode4

; mode 5 standard display list
dlist_static_mode5
        .byte $70,$70,$70
dlist_static_mode5_1st_line
        .byte $45,$00,$80
dlist_static_mode5_2nd_line
        .byte 5
dlist_static_mode5_3rd_line
        .byte 5
dlist_static_mode5_4th_line
        .byte 5
dlist_static_mode5_5th_line
        .byte 5
dlist_static_mode5_6th_line
        .byte 5
dlist_static_mode5_7th_line
        .byte 5
dlist_static_mode5_8th_line
        .byte 5
dlist_static_mode5_9th_line
        .byte 5
dlist_static_mode5_10th_line
        .byte 5
dlist_static_mode5_11th_line
        .byte 5
dlist_static_mode5_12nd_line
        .byte 5
        .byte $41,<dlist_static_mode5,>dlist_static_mode5
