; File name to load from / save to. 40 bytes is far too much for Atari DOS, probably too small for SpartaDOS.
; 40 chosen simply because it is the width of the screen, so it makes data entry easier.

FileName		.local							; File name
				.ds 40
				.endl

IOStatus		.local							; Copy of status returned by CIO
				.ds 1
				.endl
				
; Control options.

Control			.local
SingleStep		.ds 1							; Single step mode (1 = on, 0 = off)
AnalyseMode		.ds 1							; 1 = on => don't actually paint cell value, 0 = off
FastMode		.ds 1							; Fast mode (1 = DMA off, 0 = DMA on, default)
Background		.ds 1							; PM checkered background (1 = on, 0 = off)
EditMode		.ds	1							; In edit mode (cosmetic use only)
NewMode			.ds 1							; Use chose [N]ew = 1 or [E]dit = 0
				.endl
						
; Input/file IO buffer.

Buffer			.local
				.ds Constants.NCells
				.endl

; Working storage for the puzzle. Important. As this needs to extend during recursion, make sure this is always the
; last storage declared. 

Puzzle			TPuzzle		
