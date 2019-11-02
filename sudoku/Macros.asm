; Some common macros.
		
		.macro BLT location
		bcc :location
		.endm

		.macro BGT location
		bcc	skip
		bne	:location
skip:
		.endm

		.macro BGE location
		bcs :location
		.endm
		
; Convert ATASCII character in A register to internal code. MADS has option to generate ATASCII characters directly, but not internal characters,
; although this could be done by hand easily enough. But for now I'm doing this at runtime.
; Allowance is also made for inverse video (+128) characters. Making this a macro rather than a procedure to save the overhead of a JSR/RTS
; for each character. Of course one could simply wrap the macro in a procedure to do this if required.

		.macro	ATASCIIToInternal
		
; 0-31 = Control characters (line draw graphics etc) are 64-95 internally.
 
		cmp	#32
		bcc	plus64
		
; 64-95 = Digits, uppercase letters and other printable characters are 0-63 internally.

		cmp	#96
		bcc	minus32
		
; 96-127 = Lower case letters (mostly) have the same internal code, so do nothing.

		cmp	#128
		bcc	done
		
; 128-159 = Inverse video control characters (line draw graphics etc) are 192-223 internally.

		cmp	#160
		bcc	plus64
		
; 160-223 = Inverse video digits, upper case letters and other printable characters are 128-191 internally

		cmp	#224
		bcc	minus32
		
; 224-255 = Inverse video lower case letters (mostly) have the same internal code, so do nothing.

		jmp	done
		
; Add 64.

plus64:

		clc
		adc	#64
		jmp	done

; Subtract 32.

minus32:

		sec
		sbc	#32		

done:
		
		.endm

		.macro EnableCursor
		mva	#0 CRSINH
		SetCursor
		.endm
		
		.macro DisableCursor
		mva	#1 CRSINH
		SetCursor
		.endm
		
		.macro PositionXY column,row
		mva	:column Col
		mva	:row Row
		.endm
		
		.macro GotoXY column,row
		mwa :column COLCRS
		mva :row ROWCRS
		.endm

		.macro SetFlags
		mva	#Constants.SetFlags (PFlags),y
		.endm
		
; As the 9th flag is stored in the same byte as the cell value, we use some macros to abstract the logic for accessing these values.

		.macro GetFlag9
		lda (PValue),y
		and #Constants.SetFlag9Mask
		seq:lda #1
		.endm
		
		.macro ClearFlag9
		lda (PValue),y
		and #Constants.ClearFlag9Mask
		sta	(PValue),y
		.endm
		
		.macro SetFlag9
		lda (PValue),y
		ora	#Constants.SetFlag9Mask
		sta (PValue),y
		.endm
		
		.macro GetValue
		lda (PValue),y
		and #Constants.GetValueMask
		.endm

		.macro GetValueAndRecent
		lda (PValue),y
		and #(Constants.GetValueMask | Constants.SetRecentMask)
		.endm
					
		.macro SetValueSetFlag9
		ora	#Constants.SetFlag9Mask
		sta (PValue),y
		.endm
		
		.macro SetValueClearFlag9
		sta (PValue),y
		.endm
		
		.macro SetValueSetRecent
		ora	#Constants.SetRecentMask
		sta (PValue),y
		.endm
		
		.macro ClearRecent
		lda (PValue),y
		and #Constants.ClearRecentMask
		sta	(PValue),y
		.endm
			
		.macro ZeroMemory address, bytes
		ldy #0
		lda #0

loop:

		sta :address,y
		iny
		cpy #:bytes
		bne loop		
		.endm

; Zero fill a number of complete pages starting from address supplied, by rolling out STA instruction once per page.
		
		.macro ZeroPages address, pages	
		ldy #0
		lda #0
@:
		.rept :pages
		sta :address+$100*#,y
		.endr
		iny
		bne @-			
		.endm

; Simple macro to approximate CASE statement. If A = #value, call procedure then jmp to label. Otherwise fall through to next instruction.
; See MainMenu for example. This just makes the code tidier.
		
		.macro CASE value, procedure, label
		cmp #:value
		bne @+
		:procedure
		jmp :label
@:		
		.endm

; Taken from MADS Knowledge Base thread on AtariAge, where it was posted by JAC!
; I was unable to make something similar work from reading the documentation.

		.macro Info procedure
		.print ":1: " , :1, " - ", :1 + .len :1 -1, " (", .len :1,")"
		.endm