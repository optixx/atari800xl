; Group all variables into a single source file, where possible.
; This excludes precalculated data such as lookup tables, which are really constants.
; This section sits in the first $280 (640) bytes of the Player/Missle area, which is OK as we're only using players 1,2 & 3.

PCellIntersect	.local						; Pointers to cell intersection data 
Low				.ds Constants.NCells
High			.ds Constants.NCells
				.endl

PCellGroup		.local						; Pointers to cell group data
Low				.ds Constants.NGroups
High			.ds Constants.NGroups
				.endl
		
PGraphics0		.local						; Pointers to GR.0 row starts
Low				.ds Constants.Graphics0Rows
High			.ds Constants.Graphics0Rows
				.endl

PCellScreen		.local						; Pointers to cell screen addresses 
Low				.ds Constants.NCells
High			.ds Constants.NCells
				.endl
			
; Working storage for numeric conversion routines.		
		
ByteString		.local		; Buffer for converting unsigned byte to decimal string.	
				.ds 3
				.endl
		
WordString		.local		; Buffer for converting unsigned word to decimal string.
				.ds 5
				.endl
				
TimeString		.local		; Buffer for converting ticks into time in seconds.
				.ds 6
				.endl

; Cell is used during editing. Depending on context, it is sometimes easier to work with the cell index than the row and column
; numbers. Other times it is easier to use the row and column numbers. Cell is used to track the current cell position using
; both approaches.

Cell			.local		; Current edit cell.
Index			.ds 1		; Index to array of cells [0..80]
Column			.ds 1		; Grid column [0..8]
Row				.ds 1		; Grid row [0..8]
				.endl
		
; Working storage for the second insertion method (where we look for the number of cells in a group each number is permitted to appear)

Places			.local
Count			.ds Constants.GroupSize			; Number of times each value can occur in the group.
First			.ds Constants.GroupSize			; First permitted cell value can go into.
Inserted		.ds 1							; Number of insertions in current invocation.
				.endl
	
; Working storage for the main deterministic part of the solver.
					
Workspace		.local							; Working storage for deterministic solver.
Count			.ds Constants.NCells			; Number of candidates permitted for each cell.
NewValue		.ds Constants.NCells			; Permitted candidate value for each cell.
Consistent		.ds 1							; Does workspace pass consistency checks? 1 = Yes, 0 = No
Inserted		.ds 1							; Number of insertions in current pass.
GroupCount		.ds Constants.GroupSize			; Number of times a value appears within a cell group.
GuessInserted	.ds 1							; Flag to indicate there has been a guessed insertion
SliceCheck		.ds 1							; Flag to include additional checks in Knockout? 1 = Yes, 0 = No
SDMCTL			.ds	1							; Backup for SDMCTL
				.endl

; As I'm using some of the PM area for workspace, throw an error if this gets to big.
									
.print "Size of VariablesLow section = ",*-.adr(PCellIntersect)
.if *-.adr(PCellIntersect)>$280
	.error "Size of VariablesLow section is too big and would overwrite player 1. Maximum size is $280 bytes. Move some of the variables into VariablesHigh."
.endif

