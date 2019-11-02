; Structured types. This has been done as an example, there isn't a lot of benefit in this case as it seems
; MADS doesn't go as far as having a typed pointer to a structure. So, I still need assorted zero page
; pointers to parts of the data structure. However, this left in as an example.

		.struct TTrial							; Trial cell information
			Cell .byte							; Cell index
			Counter .byte 						; Local counter to use during recursion
			Value :Constants.GroupSize .byte	; Array of possible values at start of recursion process
		.ends
		
		.struct TPuzzle							; Puzzle storage
			Value :Constants.NCells .byte		; Value (bits 0-3), Flag9 (bit 4) and Recent (bit 7)
			Flags :Constants.NCells .byte		; Candidate value flags (1-8)
			Complete .byte						; Complete (1 = yes, 0 = no)
			Trial TTrial						; Cell we are guessing
		.ends