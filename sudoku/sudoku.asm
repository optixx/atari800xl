; Main source file. Assemble this, it will include subsidiary files.

; Version 0.2 - First 6502 version. 0.1 was unreleased cc65 prototype.
;         0.3 - Changed pass counter from byte to word as extreme cases caused it to wrap round.
;         0.4 - Added "Trace" option which just pauses for a keypress after each insertion.
;               Useful when manually solving a puzzle to get next cell if stuck.
;				Note this option is not shown on screen, just press "T" instead of "R".
;               Also added new KnockoutSlice procedure to add additional deterministic algorithm.
;         0.5 - Added "Fast" option (just turns DMA off). Little real value, but for bragging rights
;               this brings the time to solve "the World's hardest Sudoku" down below 1 minute.
;         0.5 - Added "Analyse" option. This solves the puzzle and shows the statistics, but neither
;               the solution nor the working. Use this to determine how hard a puzzle is and if it
;               is even solveable.
;         0.5 - Added player/missle checkerboard background, heavily based on sample code contributed
;               by AtariAge user @PIRX. Background can be toggled using the "B" key.
;         0.6 - Tidied up menu following suggestions by AtariAge user @BFOLLETT. Added "grey out" ("blue out"?)
;               of unavailable menu items by removing inverse video from first letter. Changed "Edit" to "Exit"
;               when editing to make it clearer that "E" also exits from edit mode.
;               Removed status bar code from 0.5x (experimental version) as it really adds nothing, given the
;               changes above.
;               Tweaked some of the UI code to save memory.

; Note, set tab width to 4 for correct (or at least consistent) alignment of code.
		
; System equates.

LMARGN	=	$52			; Left margin, OS defaults to 2
ROWCRS	=	$54			; Row for cursor
COLCRS	=	$55			; Column for cursor
CRSINH	=	$02F0		; Cursor inhibit (0 = on, 1 = off)
SCRENV  = 	$E410		; Screen handler vector table
KEYBDV  = 	$E420		; Keyboard handler vector table
CHBAS	= 	$02F4		; High byte of character set pointer
SAVMSC	=	$58			; Base address of screen memory
OLDCHR	=	$5D
OLDADR	=	$5E
RTCLOK	=	$12
PAL		=	$D014		; PAL/NTSC detection register in GTIA
EOL		=	$9B			; End of line character
SDMCTL	=	$22F		; Direct memory address DMA control
GPRIOR	=	$26F		; Priority selection register
PMBASE	=	$D407		
GRACTL	=	$D01D
SIZEP1	=	$D009
SIZEP2	=	$D00A
SIZEP3	=	$D00B
HPOSP0	=	$D000
HPOSP1	=	$D001
HPOSP2	=	$D002
HPOSP3	=	$D003
PCOLR1	=	$2C1
PCOLR2	=	$2C2
PCOLR3	=	$2C3
GRAFP0	=	$D00D
GRAFP1	=	$D00E
GRAFP2	=	$D00F
GRAFP3	=	$D010
DMACTL	=	$D400

; IOCB structure.
	
ICHID	=	$0340
ICDNO	=	$0341	
ICCOM	=	$0342	
ICSTA	=	$0343
ICBAL	=	$0344
ICBAH	=	$0345
ICPTL	=	$0346
ICPTH	=	$0347
ICBLL	=	$0348
ICBLH	=	$0349
ICAX1	=	$034A
ICAX2	=	$034B
ICAX3	=	$034C
ICAX4	=	$034D
ICAX5	=	$034E
ICAX6	=	$034F

CIOV	=	$E456

; CIO Command & Mode values

		.enum CIO
			OPEN	=	3
			PUT		=	11
			GET		=	7
			CLOSE	=	12
			GETTEXT	=	5
			WRITE	=	8
			READ	=	4
		.ende

; DMA control values

		.enum DMA
			NoPlayfield			=	0
			NarrowPlayfield		=	1
			StandardPlayfield	=	2
			WidePlayfield		=	3
			EnableMissleDMA		=	4
			EnablePlayerDMA		=	8
			OneLineResolution	=	16
			EnableDMA			=	32
		.ende
		
; This is just a dummy value so that it is clear in the code where an address is subject to self-modifying code.

SelfModWord	=	$FFFF
SelfModByte	=	$FF

; Application specific constants. See separate included file for string constants.

Constants			.local

GridX				=	0			; X coordinate of top left corner of grid
GridY				=	2			; Y coordinate of top left corner of grid
NCells				=	81			; Number of cells in puzzle
NIntersect			=	20			; Number of cells each cell intersects with
NGroups				=	27			; Number of cell groups
GroupSize			=	9			; Number of cells in a group
SetFlags			=	%11111111	; Set Flags 1 to 8
SetFlag9Mask		=	%00010000	; Set Flag 9
ClearFlag9Mask		=	%11101111	; Clear Flag 9
SetRecentMask		=	%10000000	; Set Recent bit
ClearRecentMask		=	%01111111	; Clear Recent bit
GetValueMask		=	%00001111	; Value is stored in lower 4 bits

Graphics0Rows		=	24
Graphics0Columns	=	40

; Screen locations of the values printed for the status display.

PassX				=	34
PassY				=	12

InsertedX			=	36
InsertedY			=	13

CompleteX			=	36
CompleteY			=	14

ConsistentX			=	36
ConsistentY			=	15

DepthX				=	36
DepthY				=	16

MemoryX				=	34
MemoryY				=	17

StackX				=	36
StackY				=	18

TimeX				=	33
TimeY				=	19

ErrorX				=	0
ErrorY				=	22

FastX				=	37
FastY				=	3

; This is the two lines beneath the grid which I'm using for file names and error messages.

PanelX				=	0
PanelY				=	21

InputX				=	0
InputY				=	22

; Number of documented errors in the error table.
; In practice, there are too many errors, but it is hard to be sure which ones to keep, especially
; as some are unlikely to surface under emulation.

NErrors				=	.adr(Tables.Errors.High) - .adr(Tables.Errors.Low)
NSlices				=	54

; Player background colour. Change to $96 if you prefer lighter background highlight.

BackgroundColour	=	$92

					.endl

; Generally better to let MADS allocate zero page variables rather than picking addresses at random.
; Default start address for program zero page variables is $80, but setting it explicitly as an aide memoire.

.zpvar	= 	$80			

.zpvar	P1				.word	; General purpose pointer 1
.zpvar	P2				.word	; General purpose pointer 2

; Pointers to various elements in the puzzle.

.zpvar	PValue			.word	; Pointer to puzzle values (including flag 9 in bit 8)
.zpvar	PFlags			.word	; Pointer to permitted value flags (1 to 8)
.zpvar 	PComplete		.word	; Pointer to complete flag
.zpvar	PTrialCell		.word	; Pointer to trial cell
.zpvar 	PTrialCounter	.word	; Pointer to trial counter
.zpvar	PTrialValue		.word	; Pointer to trial value flags

.zpvar	Pass			.word	; Pass counter
.zpvar	Depth			.byte	; Current recursion depth
.zpvar	MaxDepth		.byte	; Maximum recursion depth
.zpvar	MinStack		.byte	; Lowest value we see for the stack
.zpvar	MaxMemory		.word	; Maximum memory usage
.zpvar	Memory			.word	; Memory usage
.zpvar	Inserted		.byte	; Inserted (display only)

; Working storage for print routines which do not use the OS

.zpvar	Row				.byte	; Equivalent to ROWCRS
.zpvar	Col				.byte	; Equivalent to COLCRS

; Working storage. Should only use as part of a self-contained routine.

.zpvar	TempByte		.byte	; Temporary storage for counting bits & converting byte to decimal string
.zpvar	TempWord		.word	; Temporary storage for converting word to decimal string

; General purpose variables, typically for looping, hence traditional names.

.zpvar	I				.byte
.zpvar	J				.byte
.zpvar	K				.byte

.zpvar  SliceCount		.byte

		icl	'Types.asm'
		icl	'Macros.asm'

; Note some MADS optimisations seem to cause some problems, so safer to turn them off.
; Alternatively, I could be doing something wrong, which is perhaps more probable.
; For example, use of .var inside .proc
; In terms of code size, R+ only saves a few bytes in this application.
; As of version 0.4, this has been turned back on as clearly whatever I was doing to trigger
; the problem, I'm not doing now. Still only saves a few bytes.
; In 0.5, with the status bar, opt R+ now causes problems, unless an extra zero byte is appended to the RLE packed screen. Weird.

		opt	R+
		opt	M+

		org	$2000
		
pmg:

		icl	'VariablesLow.asm'

PLAYER1	=	pmg + $280
PLAYER2	=	pmg + $300
PLAYER3	=	pmg + $380

		org $2400
				
start:

; Initialise memory used for most variables and players. Need to do this otherwise players cause momentary screen
; corruption during initial display. Harmless, but ugly.

		ZeroPages pmg 4

; Hide cursor, remove default left margin and clear screen.

		mva	#0 LMARGN
		mva #0 Control.AnalyseMode
		mva #0 Control.FastMode
		mva	#1 Control.Background
		mva	#1 CRSINH

; Don't want to assume machine is already in graphics 0.
	
		Graphics0

; Calculate tables of addresses for the predefined cell intersect, cell group offset and screen address tables.

		GeneratePCellIntersect
		GeneratePCellGroup
		GeneratePGraphics0
		GeneratePCellScreen
		
; Draw initial screen.

		PutScreen
		InitialiseCursor
		CreatePlayerBackground
					
; Initialise puzzle pointers (equivalent to recursion depth 0) and the puzzle itself.
		
		InitialisePuzzlePointers
		NewPuzzle
		
; Main menu loop.

		MainMenu	

		PlayerBackgroundOff
		Cls

		rts
		
		run	start	
		
; Include other code files.

		icl 'Core.asm'
		icl 'RLE.asm'
		
rlescreen:	

		ins 'Screen.rle'

; This seems to be required when "opt R+" in force otherwise chaos follows.

		.byte 0

; String and lookup tables stored in separate source files for clarity.

		icl	'Strings.asm'
		icl	'Tables.asm'

; Critical to include 'VariablesHigh' last because of the way we want to extend the puzzle storage.

		icl	'VariablesHigh.asm'
					
