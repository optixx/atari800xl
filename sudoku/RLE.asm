; RLE unpacker taken from Codebase64.
; Looks less efficient than the example in the MADS distribution, which I have yet to get working!
; Possibly the packing algorithm is slightly different. Need to RTFSC!

.zpvar	RLESource	.word
.zpvar	RLETarget	.word
.zpvar	RLELastByte	.byte	
		
		.proc RLERead
		lda (RLESource),y
		inw RLESource
		rts
		.endp
		
		.proc RLEStore
		sta (RLETarget),y
		inw RLETarget
		rts
		.endp
		
		.proc RLEUnpack
		ldy #0
		RLERead
		sta RLELastByte
		RLEStore
unpack:		
		RLERead
		cmp RLELastByte
		beq rle
		sta RLELastByte
		RLEStore
		jmp unpack
rle:	
		RLERead
		tax
		beq end
		lda RLELastByte
read:
		RLEStore
		dex
		bne read
		beq unpack		
end:
		rts
		.endp
