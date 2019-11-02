; Generate lookup table for the start addresses for each cell in the CellIntersect data.
; The idea is that given a cell number, we can quickly identify the 20 cells it intersects with, without
; doing a lot of arithmetic.
; This needs to be called once during application initialisation.
; Tested = OK

		.proc GeneratePCellIntersect
		mva	#<Tables.CellIntersect P1
		sta	PCellIntersect.Low
		mva	#>Tables.CellIntersect P1+1
		sta	PCellIntersect.High
		ldy	#1

loop:

		clc
		lda	P1
		adc	#Constants.NIntersect
		sta	P1
		sta	PCellIntersect.Low,y
		lda	P1+1
		adc	#0
		sta	P1+1
		sta	PCellIntersect.High,y
		iny
		cpy	#Constants.NCells
		bne	loop
		rts
		.endp
		
		Info GeneratePCellIntersect

; Generate lookup table for the screen addresses of each cell.
; Critical to call this after GeneratePGraphics0.
; Tested = OK

		.proc GeneratePCellScreen
		ldy #0

loop:

		lda Tables.CellROWCRS,y
		tax
		clc
		lda PGraphics0.Low,x
		adc Tables.CellCOLCRS,y
		sta PCellScreen.Low,y				
		lda PGraphics0.High,x
		adc #0		
		sta PCellScreen.High,y		
		iny
		cpy #Constants.NCells
		bne loop		
		rts
		.endp

		Info GeneratePCellScreen

; Generate lookup table for the start addresses for each cell in the CellGroup data.
; Tested = OK

		.proc GeneratePCellGroup
		mva	#<Tables.CellGroup P1
		sta	PCellGroup.Low
		mva	#>Tables.CellGroup P1+1
		sta	PCellGroup.High
		ldy	#1

loop:

		clc
		lda	P1
		adc	#Constants.GroupSize
		sta	P1
		sta	PCellGroup.Low,y
		lda	P1+1
		adc	#0
		sta	P1+1
		sta	PCellGroup.High,y
		iny
		cpy	#Constants.NGroups
		bne	loop
		rts
		.endp

		Info GeneratePCellGroup
		
; Generate a lookup table for the addresses of each row in the Graphics 0 screen.
; Tested = OK

		.proc GeneratePGraphics0
		lda	SAVMSC
		sta	P1
		sta	PGraphics0.Low
		lda	SAVMSC+1
		sta	P1+1
		sta	PGraphics0.High
		ldy	#1

loop:

		clc
		lda	P1
		adc	#Constants.Graphics0Columns
		sta	P1
		sta	PGraphics0.Low,y
		lda	P1+1
		adc	#0
		sta	P1+1
		sta	PGraphics0.High,y
		iny
		cpy	#Constants.Graphics0Rows
		bne	loop
		rts
		.endp
		
		Info GeneratePGraphics0
		
; In order to make addressing easier when there are multiple puzzle "objects", I'm using a separate zero page pointer
; to each array in the object. Then each pointer can be moved up and down in memory as recursion / backtracking occurs
; and we only have a single indirection via the Y register to locate data quickly. This is wasteful of zero page
; addresses and contrasts with C where one would have a single pointer to the start of the structure. However this
; wasteful approach does simplify the programming in places.
; Tested = OK

		.proc InitialisePuzzlePointers
		mwa	#.adr(Puzzle.Value) PValue
		mwa	#.adr(Puzzle.Flags) PFlags
		mwa	#.adr(Puzzle.Complete) PComplete
		mwa	#.adr(Puzzle.Trial.Cell) PTrialCell
		mwa	#.adr(Puzzle.Trial.Counter) PTrialCounter
		mwa	#.adr(Puzzle.Trial.Value) PTrialValue
		mva	#0 Depth
		mva	#0 MaxDepth
		mwa	#0 MaxMemory
		mva	#$FF MinStack
		rts
		.endp
		
		Info InitialisePuzzlePointers
		
; I prefer to do all the editing and file IO using a separate buffer, then copy the buffer to the puzzle
; at the start of the solution. This also means the buffer is left unchanged in case the user wants to
; edit it again. It also means that we can simply write the buffer to disk in a single operation, rather
; than having to reformat the data to suit, as was done in C. As well as copying the values, the 9 
; candidate flags are also initialised.
; Tested = OK

		.proc CopyBufferToPuzzle
		ldy #0
		
loop:	

		lda Buffer,y
		ora	#Constants.SetFlag9Mask
		sta	(PValue),y
		SetFlags
		iny
		cpy	#Constants.NCells
		bne	loop	
		rts		
		.endp
		
		Info CopyBufferToPuzzle
		
; Create a new puzzle. All this does is fill the input buffer with zeros.
; Tested = OK
		
		.proc NewPuzzle
		ldy #0
		
loop:	

		mva	#0 Buffer,y
		iny
		cpy	#Constants.NCells
		bne	loop	
		rts		
		.endp
		
		Info NewPuzzle
		
; Reset the 9 candidate flags for each cell in the puzzle.
; Tested = OK

		.proc ResetPuzzleFlags
		ldy	#0

loop:

		SetFlags
		SetFlag9
		iny
		cpy	#Constants.NCells
		bne	loop	
		rts
		.endp	
		
		Info ResetPuzzleFlags
						
; Extend the array of puzzles by one and copy the data from the previous puzzle.
; Tested = OK

		.proc ExtendPuzzle
		
; Temporarily store old pointer for the value copy later.

		mwa	PValue P1

; Add size of puzzle structure to pointers and increment depth indicator.

		adw	PValue #.len(TPuzzle)
		adw	PFlags #.len(TPuzzle)
		adw	PComplete #.len(TPuzzle)
		adw	PTrialCell #.len(TPuzzle)
		adw	PTrialCounter #.len(TPuzzle)
		adw	PTrialValue #.len(TPuzzle)
		inc	Depth
		
; If necessary, update maximum depth value. This is just used in the final status display.

		lda	Depth
		cmp MaxDepth
		scc:mva Depth MaxDepth
		
; Now copy values from previous instance and set the candidate flags.

		ldy	#0

loop:

		lda (P1),y
		SetValueSetFlag9
		SetFlags
		iny
		cpy	#Constants.NCells
		bne	loop
		rts
		.endp
		
		Info ExtendPuzzle
		
; Contract the array of puzzles by one and decrement the depth indicator. Note that we simply leave
; the values hanging around in memory and just change the pointers. The values are now redundant and
; will get overwritten next time ExpandPuzzle is called.
; Tested = OK

		.proc ContractPuzzle
		sbw	PValue #.len(TPuzzle)
		sbw	PFlags #.len(TPuzzle)
		sbw	PComplete #.len(TPuzzle)
		sbw	PTrialCell #.len(TPuzzle)
		sbw	PTrialCounter #.len(TPuzzle)
		sbw	PTrialValue #.len(TPuzzle)
		dec	Depth
		rts
		.endp
		
		Info ContractPuzzle
				
; Perform full recursive solve. This is a combination of a deterministic solver (where possible),
; falling back to a recursive solver where necessary.
; Tested = OK

		.proc SolvePuzzle

; First step is to run the deterministic part of the solver and keep doing this until we get stuck.
; For simple cases we won't get stuck and the solution is trivial.
; Run one pass of the deterministic solver, run some checks for completeness and consistency, then
; update the grid and status panel.

loop:

		inw	Pass
		RunPass #0
		lda	Workspace.Inserted
		sne:RunPass #1
		CheckComplete
		CheckConsistent


		PutCells
		PutStatus

; If the puzzle is complete (Workspace.Complete = 1), then we just jump to the end.
		
		ldy	#0
		lda	(PComplete),y
		jne	done
		
; If the puzzle is not constistent (Workspace.Consistent = 0), then again we just jump to the end.

		lda	Workspace.Consistent
		beq	done

; If no cells were inserted (but the puzzle is neither complete nor inconsistent), then we have to
; start guessing cell values and solving recursively.

		lda	Workspace.Inserted
		beq	guess

; Otherwise we just loop around the deterministic solver again.

		jmp	loop

guess:
		
; Now we locate the a blank cell to try. Rather than just use the first blank cell (which is easier),
; we look for the blank cell with the smallest candidate count, ideally 2. In this way we try to 
; recurse as few times as possible. Usually we can find blank cells with small candidate counts, at
; least for real world puzzles rather than obscure test cases.

		FindTrialCell
		
; Now try each trial value. This is a little different from how candidates are handled elsewhere in
; the program because we need to work with the available candidates before the puzzle state is modified
; and recursion starts.
			
trialloop:

; Set Y = number we are trying (0-8) and X = value we are proposing to insert (1-9)

		ldy	#0
		lda	(PTrialCounter),y
		tay							
		tax
		inx	

; If the value at Y is zero, then X is not available, so we skip to the next value and try again.

		lda	(PTrialValue),y
		beq	nexttrial
		
; Set Y = index of cell we are going to insert into and A = value we are proposing to insert (X)

		ldy	#0		
		lda	(PTrialCell),y				
		tay
		txa

; Set the value and the recent insert flag. Also set the GuessInserted flag, for cosmetic reasons.

		SetValueSetRecent
		mva	#1 Workspace.GuessInserted
		
		CheckSingleStep

; Now extend the puzzle.

		ExtendPuzzle
		
; And recurse.

		SolvePuzzle
		
; If the puzzle is now complete, bail out

		ldy	#0
		lda	(PComplete),y
		bne	done
		
		ContractPuzzle
			
nexttrial:

		ldy	#0
		lda	(PTrialCounter),y
		clc
		adc	#1
		sta	(PTrialCounter),y
		cmp	#9
		bne	trialloop

done:

		rts
		.endp
		
		Info SolvePuzzle
		
; Check the initial state (as entered by the user) for consistency. Basically, if the initial
; state is not solvable, there is little point proceeding. This won't detect all unsolvable
; inputs, just those which are obviously wrong, like having two 1s on the same row.
		
		.proc CheckInitialState
		Knockout
		CheckConsistent
		rts
		.endp
		
		Info CheckInitialState
		
; Find a trial cell (blank) to use for guessing. 
; Tested = OK
		
		.proc FindTrialCell
		
; Initialise X to be the cell with the lowest candidate count and set the assumed count to 9.

		mva #9 TempByte
		ldx #0
		ldy	#0
		
; Search for a blank cell.

blankloop:

		GetValue
		beq	checkCount
		iny
		cpy	#Constants.NCells
		bne	blankloop
		jmp blankfound
		
; Compare the candidate count for this blank cell and if lower, update TempByte and X.
; So this cell is the best guess so far.

checkCount:

		lda TempByte
		cmp Workspace.Count,y
		bcc skip
		beq skip
		mva Workspace.Count,y TempByte
		tya
		tax

; Also bail out as soon as candidate count is 2, because there is no value in searching the rest. 2 is the best we can do.

skip: 
		lda TempByte			
		cmp #2
		beq blankfound

; Loop back to check other cells.
		
		iny
		cpy	#Constants.NCells
		bne	blankloop

; Having found the blank cell we are going to use, we need to try each permitted value. Safest to store these for each
; puzzle as the workspace will get changed for each new recursion. Note that the knockout does not need to be refreshed
; at this stage because there have been no insertions since the last time it was called.

; X now points to the cell with the lowest intersection count, so store this in the puzzle structure and initialise the
; counter.

blankfound:

		txa
		ldy	#0
		sta	(PTrialCell),y
		mva	#0 (PTrialCounter),y

; Erase the array of possible values.

eraseloop:
	
		sta	(PTrialValue),y
		iny
		cpy	#Constants.GroupSize
		bne	eraseloop
		
; So we can now check which values are possible in the trial cell.
; Candidates 1 to 8 first.

		ldx	#0

loop1to8:

		ldy	#0
		lda	(PTrialCell),y
		tay
		lda	(PFlags),y
		and	Tables.Bit1To8,x
		beq	next
		txa
		tay
		lda	#1
		sta	(PTrialValue),y

next:

		inx
		cpx	#8
		bne	loop1to8

; Then candidate 9 separately.

		ldy	#0
		lda	(PTrialCell),y
		tay
		GetFlag9
		ldy	#8
		sta	(PTrialValue),y
		rts		
		.endp
		
		Info FindTrialCell
				
; Perform one pass of the deterministic solve.
; Tested = OK

		.proc RunPass (.byte Workspace.SliceCheck) .var
		mva	#0 Workspace.Inserted

; Knockout candidates for each cell's intersections.

		Knockout

; Count number of candidate values for each cell.

		Count

; Then insert values for all cells with a candidate count of 1.

		InsertCount


; Then insert values where each value in a cell group can only go in one place.
; Note that the have to break these down into independent cell groups (rows, columns, boxes) and, if required, 
; run the candidate knockout routine again. This is because insertions change the state of the puzzle, forcing
; us to recalculate.	
; If nothing inserted, then we don't need to repeat the knockout code before testing for insertion by number of available places.
; MADS warning. If you put whitespace between "seq:" and "Knockout", "seq:" is silently ignored. I guess this is because it looks 
; like a label.

; Rows.
		
		lda	Workspace.Inserted
		seq:Knockout
		CountPlaces #0 #9
		InsertPlaces

; Columns.

		lda	Places.Inserted
		seq:Knockout
		CountPlaces #9 #18
		InsertPlaces

; Boxes.

		lda	Places.Inserted
		seq:Knockout
		CountPlaces #18 #27
		InsertPlaces 

		rts
		.endp
		
		Info RunPass
							
; Eliminate non-permitted values from all cells.
; Tested = OK
		
		.proc Knockout
		mva	#0 I
		#while .byte I < #Constants.NCells
		
; Get the current value in this cell and check if it has a value (!= 0)

			ldy	I
			GetValue
			beq	noaction
						
; Pointer to cell intersect table.
			
			mva	PCellIntersect.Low,y P1
			mva	PCellIntersect.High,y P1+1

; Knockout value from all 20 possible intersections.
			
			mva	#0 J
			#while .byte J < #Constants.NIntersect
			
; Want value of current cell in X.

				ldy	I
				GetValue
				tax
				
; Want index of intersected cell in Y.

				ldy	J
				lda	(P1),y
				tay
				
; Now we can knockout this value from the intersected cell.

				KnockoutValue
				inc	J
			#end
			
noaction:

		inc	I
		#end
		
; New in version 0.4, also perform additional checks to see if we can knock out further values where the placement of a value in 
; a slice of 3 cells is ambiguous. Note that this is relatively slow, so we only call this when no deterministic insertions were
; made. In effect, perform the additional logic when we get stuck to defer recursion and to reduce the chance of finding a different
; solution to that which a competent human solver would find. For example, test case published in City AM 28th July 2015.

		lda Workspace.SliceCheck
		seq:KnockoutSlice
		rts
		.endp
		
		Info Knockout
		
; KnockoutSlice deals with the following scenario.
; 1 - As a result of the Knockout routine, we know that "2" is a candidate for more than one cell in a box and that it is not the sole candidate for any cell.
; 2 - However, all such candidates cells for "2" are in the same row or column of 3 cells.
; 3 - A human solver can easily see that "2" cannot be placed in the other 6 cells on that row or column, but the existing algorithms do not allow for this.
; 4 - If this is the only possible lead to a deterministic insertion, as was the case in the puzzle which led to this development, the program would previously
;     have started recursing, eventually leading to a solution. In the test case I was looking at, this led to a different solution to the one arising from a 
;     manual solution.
; So, KnockoutSlice performs this additional logic check, reducing the need to start recursing and increasing the chance of coming up with the same solution
; as a human solver might. Unfortunately, this is a relatively expensive operation and does increase the runtime noticably, unless we only call it when we
; get stuck.
; Tested = OK
  		
		.proc KnockoutSlice
		mva	#0 I
		#while .byte I < #Constants.NSlices

; In each slice (I) of 3 cells (of which there are 54 = 9 boxes x 3 columns x 2 for rows), consider each possible value (J = [1..9]).
		
			mva	#1 J
			#while .byte J < #10
			
; Count the number of cells in the slice for which the number J is a candidate. As soon as we get one match we can stop counting as one is sufficent.
; Then, if the count is still zero, take no further action and loop round to the next number.

				mwa #.adr(Tables.Slices.In1) selfmod1
				mva #0 SliceCount
				mva #0 K
				#while .byte K < #3
selfmod1			equ *+3
					CheckCandidate
					bne outchecks
					adw selfmod1 #Constants.NSlices
					inc K
				#end
				lda SliceCount
				beq noaction
				
; Now count the number of cells in the other 6 cells in the box for which the number J is a candidate. If J is a candidate in any of these, 
; then we can again take no further action, so we bail out as soon as one candidate is detected.
				
outchecks:

				mwa #.adr(Tables.Slices.NotIn1) selfmod2
				mva #0 SliceCount
				mva #0 K
				#while .byte K < #6
selfmod2			equ *+3
					CheckCandidate
					bne noaction
					adw selfmod2 #Constants.NSlices
					inc K
				#end

; If we get here, then we know that J is a candidate in the slice, but not a candidate for the other two slices in the box, then we can knock out
; the number J from the other 6 cells on the same row or column as the original slice.

				mwa #.adr(Tables.Slices.Knockout1) selfmod3
				mva #0 K
				#while .byte K < #6
					ldx I
selfmod3			equ *+1
					ldy SelfModWord,x
					ldx J
					KnockoutValue
					adw selfmod3 #Constants.NSlices
					inc K
				#end
						
noaction:

				inc J
			#end
			inc I
		#end
		rts
		.endp
		
		Info KnockoutSlice
		
; Macro to check if number J in cell I is a candidate for insertion or not. That is, it has not already been
; knocked out, or the cell is in use. Note macro placed here as it is really not very generic.
; Warning. The second line, "ldy SelfModWord,x" is subject to modification of the address by the main code.
; So, if the relative position of this address reference gets changed, the calling code also needs to be changed
; otherwise stuff breaks.
; Tested = OK
		
		.macro CheckCandidate
		ldx I
		ldy SelfModWord,x
		GetValue
		bne @+
		ldx J
		IsCandidate
		seq:inc SliceCount			
@:

; Note that we do need to reload the count into A to trigger an implicit comparison so that we can branch as required in the
; main code.
		
		lda SliceCount
		.endm


; Check if value in X in cell Y is a candidate or not.
; A = 0 for false, != 0 for true.
; Tested = OK

		.proc IsCandidate
		cpx #9
		beq @+
		dex
		lda (PFlags),y
		and Tables.Bit1To8,x
		rts
@:
		GetFlag9			
		rts
		.endp
		
		Info IsCandidate
							
; Knockout value X in cell Y.
; Tested = OK

		.proc KnockoutValue
		cpx	#9
		beq	process9
		dex
		lda	(PFlags),y
		and	Tables.Mask1To8,x
		sta	(PFlags),y
		rts
		
process9:
	
		ClearFlag9
		rts
		.endp
		
		Info KnockoutValue
				
; Count number of candidates for each cell. Note that this is transient information, so we can use the fixed workspace.
; Tested = OK

		.proc Count
		mva	#0 I
		#while .byte I < #Constants.NCells

; Zero counter and suggested new value. Then check if cell has a value and bail out if it does.

			ldy	I
			mva	#0 Workspace.Count,y
			mva	#0 Workspace.NewValue,y
			GetValue
			bne	next
			
; First count flags for 1 to 8. Actually we start from 8 and count down because the first ROL rotates bit 8 into the carry flag.
; We use a temporary location for the count because the code destroys the original value. Storage of NewValue looks odd because
; we are overwriting with each permitted value. This is OK because it is only used when count == 1.

			mva	(PFlags),y TempByte
			ldx	I
			ldy	#8
			clc
			
rolloop:
			rol	TempByte
			bcc	notset			
			inc	Workspace.Count,x
			tya
			sta	Workspace.NewValue,x

notset:

			dey
			bne	rolloop
			
; Now handle the 9th bit.

			ldy	I
			GetFlag9
			beq	next
			inc	Workspace.Count,x
			mva	#9 Workspace.NewValue,x					

next:

			inc I
		#end	
		rts
		.endp
		
		Info Count
				
; Insert values into cells which can only contain a single value. This also sets the recent flag
; for inserted cells so that when we display them, we know to do so in inverse video.
; Tested = OK

		.proc InsertCount
		ldy	#0
		
loop:

		GetValue
		bne	done
		lda	Workspace.Count,y
		cmp	#1
		bne	done
		lda Workspace.Newvalue,y
		SetValueSetRecent
		inc	Workspace.Inserted
		
; If single step on, bail after first insertion.
		
		CheckSingleStep
		
done:

		iny
		cpy	#Constants.NCells
		bne	loop
		
exit:

		rts
		.endp
		
		Info InsertCount
		
; Count the number of places within a cell group into which each value can be placed.
; Tested = OK

		.proc CountCellGroupPlaces
		
; First erase counts. Note that Places.First is initialised to -1 so that when we increment it, it
; references element 0, which is the first one.

		ldy	#0
		
eraseloop:

		mva	#0 Places.Count,y
		mva	#$FF Places.First,y
		iny
		cpy	#Constants.GroupSize
		bne	eraseloop
		
; Now need a pointer to the cell group lookup table for this cell.

		ldy	I
		mva	PCellGroup.Low,y P1
		mva	PCellGroup.High,y P1+1

		mva	#0 J
		#while .byte J < #Constants.GroupSize
		
; Want Y to reference current cell in this cell group

			ldy	J
			mva	(P1),y K
			ldy	K
	
; If cell is filled in, then we can't consider it.

			GetValue
			bne	next
			
; So now add the possible values for this cell into the counts. As usual, we start with 1-8.

			ldx	#0
			ldy	K

loop1to8:

			lda	(PFlags),y
			and	Tables.Bit1To8,x
			beq	nextx
			inc	Places.Count,x
			lda	Places.Count,x
			cmp	#1
			bne	nextx
			tya
			sta	Places.First,x

nextx:

			inx
			cpx	#8
			bne	loop1to8
			
; Is 9 permitted for this cell? X equals 8 at this point which is the right offset.

			GetFlag9
			beq	next
			inc	Places.Count,x
			lda	Places.Count,x
			cmp	#1
			bne	next
			tya
			sta	Places.First,x			

next:

			inc J
		#end
		rts		
		.endp
		
		Info CountCellGroupPlaces
		
; For each cell group in the specified range (which is effectively all rows, columns or boxes), identify values which
; can only be placed in single cells, then prepare them for insertion. This is split out because, of course, rows
; columns and boxes overlap and if we didn't do this the algorithm breaks down.
; Tested = OK
		
		.proc CountPlaces(.byte From .byte To) .var
		.var From .byte
		.var To .byte
		
; First erase the NewValue in Workspace for all cells.

		lda	#0
		ldy	#0
		
eraseloop:

		sta	Workspace.NewValue,y
		iny
		cpy	#Constants.NCells
		bne	eraseloop
		
		mva	From I
		#while .byte I < To
			CountCellGroupPlaces
			ldx	#0
			
insertloop:

			lda	Places.Count,x
			cmp	#1
			bne	next
			
; This value can be inserted into exactly once place (Permitted.First), so transfer the value into Workspace.NewValue.
; Note value to be stored A = X + 1.

			lda	Places.First,x
			tay
			inx
			txa
			dex
			sta	Workspace.NewValue,y

next:

			inx
			cpx	#9
			bne	insertloop
			inc	I
		#end
		rts
		.endp
		
		Info CountPlaces
				
; Where values can only be placed into single cells, insert them and set the recent flag.
; Tested = OK

		.proc InsertPlaces
		mva	#0 Places.Inserted
		ldy	#0
		
loop:

		lda	Workspace.NewValue,y
		beq	done
		SetValueSetRecent
		inc	Workspace.Inserted
		inc	Places.Inserted
		
		CheckSingleStep
		
done:

		iny
		cpy	#Constants.NCells
		bne	loop
		
exit:

		rts
		.endp
		
		Info InsertPlaces
		
; Is puzzle complete (1) or not (0).
; Tested = OK

		.proc CheckComplete

; Assume it is complete.

		ldy	#0
		mva	#1 (PComplete),y
		mva	#0 I	
		#while .byte I < #Constants.NCells
			ldy	I
			GetValue
			bne	next
			ldy	#0
			mva	#0 (PComplete),y
			rts
			
next:

			inc	I
		#end
		rts
		.endp
		
		Info CheckComplete
				
; Check puzzle and current workspace are consistent. When using recursion, wrong guesses will put the puzzle into an inconsistent
; state and the solution process breaks down. When this happens we need to detect it and bail out.
; Tested = OK

		.proc CheckConsistent
		
; Assume it is consistent.

		mva	#1 Workspace.Consistent
		ldy	#0
		
; Cells with values are assumed to be OK. This is not strictly true as there may be duplicates which we'll detect later.
; Duplicate detection is relatively slow, so we don't do this unless necessary.

loop:

		GetValue
		bne	next
		
; Check that the cell has some candidates, otherwise the puzzle is inconsistent.

		lda	(PFlags),y
		bne	next
		GetFlag9
		bne next
		mva	#0 Workspace.Consistent
		rts

next:

		iny
		cpy	#Constants.NCells
		bne	loop

; Also, we may have duplicates inserted as part of the recursion process.

		mvx	#0 I

nextGroup:	

		mva	PCellGroup.Low,x P1
		mva	PCellGroup.High,x P1+1
		
; Clear count of each value within this cell group.

		ldx	#0
		lda	#0

eraseLoop:

		sta	Workspace.GroupCount,x
		inx
		cpx	#Constants.GroupSize
		bne	eraseLoop

; Search for duplicates in this cell group. Bail out as soon as one duplicate is detected.

		mvy	#0 J

checkDuplicateLoop:

		lda	(P1),y
		tay
		GetValue
		beq	ok
		tax
		dex
		inc	Workspace.GroupCount,x
		lda	Workspace.GroupCount,x
		cmp	#2
		bne	ok
		mva	#0 Workspace.Consistent
		rts

ok:

		inc	J
		ldy	J
		cpy	#Constants.GroupSize
		bne	checkDuplicateLoop
		
; Check next cell group

		inc	I
		ldx	I
		cpx	#Constants.NGroups
		bne	nextGroup
		rts	
		.endp
		
		Info CheckConsistent
		
; Print cells to screen, inside the grid.
; Starting from v0.5, optionally do nothing for the new Analyse mode.
; Tested = OK
				
		.proc PutCells
		lda Control.AnalyseMode
		bne done
		ldy #0
		ldx #0
		
loop:

		mva PCellScreen.Low,y P1
		mva PCellScreen.High,y P1+1
		GetValueAndRecent
		beq iszero
		clc
		adc #16
		
iszero:

; Put the cell value on the screen, then clear the recent flag. Note that because the recent
; flag is bit 7 of the value, this automatically makes the character inverse video.

		sta (P1,x)
		ClearRecent
		iny
		cpy #Constants.NCells
		bne loop
done:	rts
		.endp
		
		Info PutCells
		
; Put cells to screen, inside the grid, taking values from the input buffer rather than the
; puzzle. This is for loading from disk and so on.		
; Tested = OK
		
		.proc PutBufferCells
		ldy #0
		ldx #0
		
loop:

		mva PCellScreen.Low,y P1
		mva PCellScreen.High,y P1+1
		lda Buffer,y
		beq iszero
		clc
		adc #16
		
iszero:

		sta (P1,x)
		iny
		cpy #Constants.NCells
		bne loop
		rts
		.endp
		
		Info PutBufferCells
								
; Get character from the keyboard in A, using the OS.		
; Tested = OK

		.proc GetChar
		lda	KEYBDV+5
		pha
		lda	KEYBDV+4
		pha
		rts
		.endp
		
		Info GetChar
		
; Display character in A at current screen position and advance the cursor position, using the OS.
; Tested = OK
		
		.proc PutChar	
		tax
		lda	SCRENV+7
		pha
		lda	SCRENV+6
		pha
		txa
		rts
		.endp
		
		Info PutChar

; Handle "New" option from main menu.
;Tested = OK, 11 October 2015
					
		.proc MainMenuNew
		mva #1 Control.NewMode
		MainMenuEditNewCore
		rts
		.endp
		
		Info MainMenuNew

; Handle "Edit" option from main menu.
; Tested = OK, 11 October 2015
				
		.proc MainMenuEdit
		mva #0 Control.NewMode
		MainMenuEditNewCore
		rts
		.endp
		
		Info MainMenuEdit

; Shared code to handle "New" and "Edit" options from main menu. The only difference between these
; two is the need to clear the buffer for the "New" option.
; Tested = OK, 11 October 2015
		
		.proc MainMenuEditNewCore
		ClearIOError
		InitialisePuzzlePointers
		lda Control.NewMode
		seq:NewPuzzle
		PutBufferCells
		ClearStatus
		InitialiseCursor
		mva #1 Control.EditMode
		EditMenu
		mva #0 Control.EditMode
		rts
		.endp
		
		Info MainMenuEditNewCore

; Handle "Undo" option from main menu.
; This removes the solution and status results so the puzzle can be solved again.
; Tested = OK, 11 October 2015
		
		.proc MainMenuUndo
		ClearIOError
		InitialisePuzzlePointers
		PutBufferCells
		ClearStatus
		rts
		.endp
		
		Info MainMenuUndo

; Handle "Load" option from main menu. Loads a puzzle from (usually) a disk or disk image.
; Tested = OK, 11 October 2015
		
		.proc MainMenuLoad
		HideMenuItems
		ClearPanel
		PrintAt #Constants.PanelX #Constants.PanelY LoadFilePrompt
		GetFileName
		LoadBuffer
		PutScreen
		ShowIOError
		lda	IOStatus
		bmi loadFail
		InitialisePuzzlePointers
		PutBufferCells
		
loadFail:

		rts
		.endp
		
		Info MainMenuLoad

; Handle "Save" option from main menu. Saves a puzzle to (usually) a disk or disk image.
; Tested = OK, 11 October 2015
		
		.proc MainMenuSave
		HideMenuItems
		ClearPanel
		PrintAt #Constants.PanelX #Constants.PanelY SaveFilePrompt
		GetFileName
		SaveBuffer
		PutScreen
		ShowIOError
		PutBufferCells
		rts
		.endp
		
		Info MainMenuSave

; Handle "Run" option from main menu.
; Tested = OK, 11 October 2015
		
		.proc MainMenuRun
		mva #0 Control.AnalyseMode
		MainMenuRunAnalyseCore
		rts
		.endp
		
		Info MainMenuRun

; Handle "Trace" option from main menu. Slightly useful for debugging, but only slightly.
; Tested = OK, 11 October 2015
		
		.proc MainMenuTrace
		HideOtherMenuItems
		ClearIOError
		mva	#1 Control.SingleStep
		mva #0 Control.AnalyseMode
		RunSolver
		ShowMenuItems
		rts
		.endp
		
		Info MainMenuTrace

; Handle "Analyse" option from main menu. Runs solver without showing the results.
; Tested = OK, 11 October 2015
		
		.proc MainMenuAnalyse
		mva #1 Control.AnalyseMode
		MainMenuRunAnalyseCore
		rts
		.endp
		
		Info MainMenuAnalyse
	
; Shared code for the "Run" and "Analyse" main menu options. Only real difference is one setting (Control.AnalyseMode).
; Tested = OK, 11 October 2015
						
		.proc MainMenuRunAnalyseCore
		HideMenuItems
		ClearIOError
		mva #0 Control.SingleStep
		FastModeOn
		lda Control.FastMode
		bne @+
		lda Control.Background
		seq:PlayerBackgroundOff
@:		RunSolver
		lda Control.FastMode
		bne @+
		lda Control.Background
		seq:PlayerBackgroundOn
@:		FastModeOff
		ShowMenuItems
		rts
		.endp

		Info MainMenuRunAnalyseCore

; Handle "Fast" option from the main menu. This just toggles the flag indicating that DMA should be disabled
; while the solver is running, which trims about 30% off the run time at the cost of no display.
; Tested = OK, 11 October 2015
								
		.proc MainMenuFastModeToggle
		ClearIOError
		lda Control.FastMode
		eor #1
		sta Control.FastMode
		beq @+
		PrintAt #33 #5 Strings.On
		rts
@:		PrintAt #33 #5 Strings.Off
		rts
		.endp
		
		Info MainMenuFastModeToggle

; Handle "Background" option from the main menu. This just toggles the display of the Player/Missle
; background designed by @PIRX.
; Tested = OK, 11 October 2015
					
		.proc MainMenuBackgroundToggle
		ClearIOError
		lda Control.Background
		eor #1
		sta Control.Background
		beq @+
		PlayerBackgroundOn
		rts
@:		PlayerBackgroundOff
		rts
		.endp
		
		Info MainMenuBackgroundToggle
																			
; Process the main menu. This just loops round polling the keyboard and responds to selected keypresses.
; Returns when the user presses 'Q'.
; Reworked using a trivial CASE macro and procedures for each action as it was getting unwieldy.
; Tested = OK

		.proc MainMenu

loop:
		
; Get character from keyboard and convert to lower case (only valid for actual letters).

		GetChar
		ora	#32
		
; N = new puzzle

		CASE 'n', MainMenuNew, loop
		
; E = edit mode toggle. In this context, this will enter edit mode calling the EditMenu procedure.

		CASE 'e', MainMenuEdit, loop
	
; U = undo solve (this is very similar to edit, user could just press E twice and get much the same result).

		CASE 'u', MainMenuUndo, loop
		
; L = load puzzle.

		CASE 'l', MainMenuLoad, loop
		
; S = save puzzle.

		CASE 's', MainMenuSave, loop
		
; R = Run solver.

		CASE 'r', MainMenuRun, loop
		
; T = Trace / Single Step
; Note this isn't either much use or well implemented.
; Because of the way the deterministic solver works at the pass level, the order in which cells are shown is usually unhelpful.

		CASE 't', MainMenuTrace, loop

; A = Analyse Mode, basically Run solver but don't print the cells.

		CASE 'a', MainMenuAnalyse, loop

; F = toggle DMA on/off ("fast" mode).

		CASE 'f', MainMenuFastModeToggle, loop
	
; B = toggle background on/off

		CASE 'b', MainMenuBackgroundToggle, loop
						
; Q = quit program.

		cmp	#'q'
		beq	done
		
; Loop back for another keypress.
						
		jmp	loop

done:

		rts
		.endp
		
		Info MainMenu
		
; If required, activate fast mode (DMA off).
; Tested = OK

		.proc FastModeOn
		lda Control.FastMode
		beq @+
		mva SDMCTL Workspace.SDMCTL
		mva #0 SDMCTL
@:		rts
		.end
		
		Info FastModeOn
				
; If required, deactivate fast mode (DMA on).
; Tested = OK

		.proc FastModeOff
		lda Control.FastMode
		seq:mva Workspace.SDMCTL SDMCTL
		rts
		.endp	
		
		Info FastModeOff
		
; Set / update cursor. It was borrowed from the CC65 library and fiddled with. It might need more work.
; Tested = OK (more or less).

		.proc SetCursor

; Restore saved value (if cursor is on).
 
 		ldy #0
		lda OLDCHR
		sta (OLDADR),y

; Calculate address on screen.

		ldy	ROWCRS
		lda PGraphics0.Low,y
		clc
		adc COLCRS
		sta OLDADR
		lda PGraphics0.High,y
		adc #0
		sta OLDADR+1
		
; Get current character from screen and store.

		ldy	#0
		lda	(OLDADR),y
		sta	OLDCHR
		ldx	CRSINH
		beq	on
		and	#$7F
		sta	(OLDADR),y
		rts
	
on:

		ora	#$80
		sta	(OLDADR),y
		rts
		.endp
		
		Info SetCursor
		
; Move to next cell, looping back to 0 if already at the end of the grid (cell 80).
; Tested = OK

		.proc AdvanceCursor
		ldx Cell.Index
		cpx #(Constants.NCells-1)
		bne	move
		ldx #$FF

move:

		inx
		stx	Cell.Index
		rts
		.endp
		
		Info AdvanceCursor
		
; Move to previous cell, looping back to 80 if already at the start of the grid (cell 0).
; Tested = OK

		.proc RetreatCursor
		ldx	Cell.Index
		bne	move
		ldx #Constants.NCells

move:

		dex
		stx	Cell.Index
		rts
		.endp
		
		Info RetreatCursor
		
; Move the cursor to the onscreen position of the current cell.
; Tested = OK

		.proc MoveCursor
		ldy	Cell.Index
		lda Tables.CellCOLCRS,y
		sta COLCRS
		lda Tables.CellROWCRS,y
		sta ROWCRS
		lda #0
		sta COLCRS+1
		SetCursor
		rts
		.endp
		
		Info MoveCursor

; Handle "left arrow" action while editing.
; Tested = OK, 11 October 2015
		
		.proc EditMenuLeftArrow
		ldx	Cell.Column
		bne	@+
		ldx	#9

@:

		dex
		stx	Cell.Column
		RowColToCellIndex
		MoveCursor
		rts
		.endp
		
		Info EditMenuLeftArrow

; Handle "right arrow" action while editing.
; Tested = OK, 11 October 2015
		
		.proc EditMenuRightArrow
		ldx	Cell.Column
		cpx	#8
		bne	@+
		ldx	#$FF

@:

		inx
		stx	Cell.Column
		RowColToCellIndex
		MoveCursor
		rts
		.endp
		
		Info EditMenuRightArrow

; Handle "up arrow" action while editing.
; Tested = OK, 11 October 2015
		
		.proc EditMenuUpArrow			
		ldx	Cell.Row
		bne	@+
		ldx	#9

@:

		dex
		stx	Cell.Row
		RowColToCellIndex
		MoveCursor
		rts
		.endp
		
		Info EditMenuUpArrow

; Handle "down arrow" while editing.
; Tested = OK, 11 October 2015
							
		.proc EditMenuDownArrow
		ldx	Cell.Row
		cpx	#8
		bne	@+
		ldx	#$FF

@:

		inx
		stx	Cell.Row		
		RowColToCellIndex
		MoveCursor
		rts
		.endp
		
		Info EditMenuDownArrow

; Handle user pressing a number key while editing.
; Tested = OK, 11 October 2015
				
		.proc EditMenuDigit
		tax
		sec
		sbc	#$30
		ldy	Cell.Index
		sta Buffer,y
		txa
		PutChar
		AdvanceCursor
		CellIndexToRowCol
		MoveCursor
		rts
		.endp
		
		Info EditMenuDigit

; Handle user pressing "space" while editing.
; Tested = OK, 11 October 2015
				
		.proc EditMenuSpace
		tax
		ldy	Cell.Index
		lda #0
		sta Buffer,y
		txa
		PutChar
		AdvanceCursor
		CellIndexToRowCol
		MoveCursor
		rts
		.endp
		
		Info EditMenuSpace

; Handle user pressing "backspace" while editing.
; Tested = OK, 11 October 2015
						
		.proc EditMenuBackspace
		ldy	Cell.Index
		lda #0
		sta Buffer,y
		lda	#$20
		PutChar
		RetreatCursor		
		CellIndexToRowCol
		MoveCursor
		rts
		.endp
		
		Info EditMenuBackspace
		
; "Grey out" all menu options
; Tested = OK, 11 October 2015

		.proc HideMenuItems
		HideTraceMenuItems
		HideOtherMenuItems
		rts
		.endp
		
		Info HideMenuItems

; "Grey out" menu items NOT relevant to the "Trace" option.
; Tested = OK, 11 October 2015
				
		.proc HideOtherMenuItems
		NormalCharAt #21 #3
		NormalCharAt #21 #4
		NormalCharAt #21 #5
		NormalCharAt #21 #6
		NormalCharAt #21 #8
		NormalCharAt #28 #3
		NormalCharAt #28 #5
		NormalCharAt #28 #6
		NormalCharAt #28 #8
		rts
		.endp
		
		Info HideOtherMenuItems

; "Grey out" menu items relevant to the "Trace" option.
; Tested = OK, 11 October 2015
				
		.proc HideTraceMenuItems
		NormalCharAt #21 #7
		NormalCharAt #28 #4
		rts
		.endp
		
		Info HideTraceMenuItems

; "Show / remove grey out" from all menu items.
; Tested = OK, 11 October 2015
				
		.proc ShowMenuItems
		InverseCharAt #21 #3
		InverseCharAt #21 #4
		InverseCharAt #21 #5
		InverseCharAt #21 #6
		InverseCharAt #21 #7
		InverseCharAt #21 #8
		InverseCharAt #28 #3
		InverseCharAt #28 #4
		InverseCharAt #28 #5
		InverseCharAt #28 #6
		InverseCharAt #28 #8
		rts
		.endp
		
		Info ShowMenuItems
					
; Edit menu.
; Tested = OK

		.proc EditMenu
		
		HideMenuItems
		PrintAt #21 #4 Strings.Exit
				
; On entry, move to first cell and enable the cursor.

		mva	#Constants.GridY+1 ROWCRS
		mwa	#Constants.GridX+1 COLCRS
		mva	#0 Cell.Index
		CellIndexToRowCol
		EnableCursor

loop:

		GetChar		
	
; Left arrow, wrapping to end of row if at first column.

		CASE 30, EditMenuLeftArrow, loop
			
; Right arrow, wrapping to start of row if at last column.

		CASE 31, EditMenuRightArrow, loop	
			
; Up arrow, wrapping to end of columm if at first row.

		CASE 28, EditMenuUpArrow, loop

; Down arrow wrapping to start of column if at last row.

		CASE 29, EditMenuDownArrow, loop
		
; Digits. Enter digit 1-9 then advance cursor to next cell.
; CASE macro doesn't do ranges. No point writing a macro for this, situation only occurs once in the program.

testDigit:

		cmp	#49
		bcc	@+
		cmp	#58
		bcs	@+
		EditMenuDigit	
		jmp	loop

; Space. Erase value in current cell then advance cursor to next cell.
		
@:

		CASE $20, EditMenuSpace, loop	

; Backspace. Erase value in current cell then retreat cursor to previous cell.

		CASE $7E, EditMenuBackspace, loop
		
; Exit?

		ora	#32
		cmp	#'e'
		beq	done
		jmp	loop

done:

; Turn off cursor before exit.

		DisableCursor
		ShowMenuItems
		PrintAt #21 #4 Strings.Edit
		rts
		.endp
		
		Info EditMenu
		
; Run solver. This is just a wrapper for the main solver, with initialisation and final display.
; Tested = OK
		
		.proc RunSolver

; Reset clock (RTCLOK) so we can get an approximate runtime.

		ResetClock

; Reset the puzzle pointers eliminating effect of any previous recursion.

		InitialisePuzzlePointers

; Initialise puzzle from the input buffer.

		CopyBufferToPuzzle

; Check initial puzzle state is consistent (as far as is possible) and prevent solver from running
; if inconsistent.

		CheckInitialState
		lda	Workspace.Consistent
		beq	bad
		
; Run solver.

		mwa	#0 Pass
		mva #0 Workspace.GuessInserted
		SolvePuzzle

; Display final state of cells. This is to remove the inverse video from the cells inserted in the 
; final pass.
		
		PutCells

bad:

; Show status and final status. There is a small amount of duplication here because PutStatus will
; already have been invoked, but for simplicity this is fine as it stands.

		PutStatus
		PutFinalStatus
				
		rts
		.endp	
		
		Info RunSolver
					
; Clear screen. As we are using the OS, simply printing character 125 does this for us.
; Tested = OK
		
		.proc Cls
		lda	#125
		PutChar
		rts
		.endp
		
		Info Cls
				
; Paint entire screen. As unpacking RLE encoded data is pretty quick, and if the repetitive grid is handled in code, RLE compression reduces
; the rest of the screen to ~370 bytes, down from 960. The code to unpack RLE is only ~60 bytes. 
; Tested = OK

		.proc PutScreen
		mwa SAVMSC RLETarget
		mwa #.adr(rlescreen) RLESource
		RLEUnpack
		mva #2 Row
		mva #0 Col
		PrintAt Col Row Strings.SG1
		#while .byte Row < #18
			inc Row
			PrintAt Col Row Strings.SG2
			inc Row
			PrintAt Col Row Strings.SG3
		#end
		inc Row
		PrintAt Col Row Strings.SG2
		inc Row
		PrintAt Col Row Strings.SG4
		rts
		.endp
		
		Info PutScreen
				
; Print "Yes" or " No" at specified coordinates based on value in A.
; Note A BEFORE X & Y for case when A loaded using indexed addressing. Also explains need for CMP instruction.
; Tested = OK, 11 October 2015

		.proc PrintYesNoAt (.byte a,x,y) .reg
		cmp #0
		beq @+
		mwa #.adr(Strings.Yes) PrintAtCore.Address
		mva #.len(Strings.Yes) PrintAtCore.Length
		jmp print

@:

		mwa #.adr(Strings.No) PrintAtCore.Address
		mva #.len(Strings.No) PrintAtCore.Length

print:	

		PrintAtCore
		rts		
		.endp
		
		Info PrintYesNoAt

; Macro to set up PrintAtCore depending on circumstances in which we want to use it.
		
		.macro PrintAt x, y, address, length
		.if :0=4
			ldx :x
			ldy :y
			mwa :address PrintAtCore.Address
			mva :length PrintAtCore.Length
			PrintAtCore
		.elseif :0=3
			ldx :x
			ldy :y
			mwa #.adr(:address) PrintAtCore.Address
			mva #.len(:address) PrintAtCore.Length
			PrintAtCore	
		.else
			.error "Usage: PrintAt x, y, address, length OR PrintAt x, y, local"
		.endif
		.endm

; Macro to set up PrintBlankAtCore.
		
		.macro PrintBlankAt x, y, length
		ldx :x
		ldy :y
		mva :length PrintBlankAtCore.Length
		PrintBlankAtCore
		.endm
		
; On entry registers (X,Y) denote screen position. String length assumed > 0 (if = 0 why are you calling this?)
; According to Zaks, STA ABS,Y is 1 cycle faster than STA (ZP),Y.
; Advantage to this is that it requires no ZP use.
; Drawback is X + LEN must be <= 255 (unlikely to be a problem in practice). This saves a 16 bit addition.
; Tested = OK, 11 October 2015

		.proc PrintAtCore
		mva	PGraphics0.Low,y Target
		mva	PGraphics0.High,y Target+1
		ldy #0

Address = *+1

@:		

		lda SelfModWord,y

Target = *+1

		sta SelfModWord,x
		inx
		iny

Length = *+1

		cpy #SelfModByte
		bne @- 		
		rts
		.endp
		
		Info PrintAtCore

; Core routine for printing spaces at specified position.
; Tested = OK, 11 October 2015
				
		.proc PrintBlankAtCore
		mva	PGraphics0.Low,y Target
		mva	PGraphics0.High,y Target+1

Length = *+1

		ldy #SelfModByte
		lda #0

Target = *+1

@:

		sta SelfModWord,x
		inx
		dey
		bne @-
		rts
		.endp

		Info PrintBlankAtCore

; Invert (toggle inverse video) of character at specified position.
; Note not currently used, but left in as MADS will optimise it away with the correct option.
; Tested = OK
				
		.proc InvertCharAt (.byte x,y) .reg
		mva	PGraphics0.Low,y P2
		mva	PGraphics0.High,y P2+1
		txa
		tay
		lda (P2),y
		eor #%10000000
		sta (P2),y
		rts
		.endp
		
		Info InvertCharAt

; Set character at specified position to normal video.
; Tested = OK, 11 October 2015
				
		.proc NormalCharAt (.byte x,y) .reg
		mva	PGraphics0.Low,y P2
		mva	PGraphics0.High,y P2+1
		txa
		tay
		lda (P2),y
		and #%01111111
		sta (P2),y
		rts
		.endp
		
		Info NormalCharAt

; Set character at specified position to inverse video.
; Tested = OK, 11 October 2015
				
		.proc InverseCharAt (.byte x,y) .reg
		mva	PGraphics0.Low,y P2
		mva	PGraphics0.High,y P2+1
		txa
		tay
		lda (P2),y
		ora #%10000000
		sta (P2),y
		rts
		.endp	
		
		Info InverseCharAt
						
; OK, this is slight speculation, but it seems that because I'm bypassing the OS for most of the screen writing,
; but am using it for input, the SetCursor routine is in an ambiguous state on first use. On first entry, the code
; to deal with the previous value fails, wiping out the first character on the screen. The simplest solution is to
; initialise the OLDADR and OLDCHR system variables after printing the screen. Actually, needs calling in a few
; places.
; Tested = OK
		
		.proc InitialiseCursor
		ldy #0
		mva (SAVMSC),y OLDCHR
		mwa SAVMSC OLDADR
		rts		
		.endp
		
		Info InitialiseCursor				
		
; Convert current cell index 0-80 to row and col, both 0-8.
; Tested = OK

		.proc CellIndexToRowCol
		ldy	#0
		lda	Cell.Index

loop:

		cmp	#9
		blt	done
		iny
		sec
		sbc	#9
		jmp	loop
		
done:

		sty Cell.Row
		sta Cell.Column
		rts
		.endp
		
		Info CellIndexToRowCol
		
; Convert row and col to cell index.
; Tested = OK

		.proc RowColToCellIndex
		lda	Cell.Column
		ldy Cell.Row
		beq done
		clc

loop:

		adc	#9
		dey
		bne	loop	

done:

		sta	Cell.Index
		rts
		.endp
		
		Info RowColToCellIndex
		
; Convert (unsigned) byte to a string in decimal format, right aligned, leading zeros removed by
; repeated subtraction of powers of 10.
; Tested = OK

		.proc ConvertByteToDecimalString (.byte TempByte) .var
		ldy	#0
		
power10loop:

		ldx	#"0"

; Compare with the current power of 10. If there are no units left, move on to the next power.

countloop:

		lda	TempByte
		cmp	Tables.Power10.Low100,y
		bcc	nextpower

; Subtract the current power of 10 and increment the count. Then jump back to check for more units.

		sec
		sbc	Tables.Power10.Low100,y
		sta	TempByte
		inx
		jmp	countloop		

; Store the current digit. We started counting from the character for '0', so this is trivial.

nextpower:

		txa
		sta	ByteString,y
		iny	
		cpy	#2
		bne	power10loop

; Finally, whatever is left is the last digit, so just add '0' to this and store it.

		lda	TempByte
		clc
		adc	#"0"
		sta	ByteString,y		
		
; Now remove leading zeros, if any. Bail out on first non-zero and don't look at the last digit.

		ldy	#0

zeroloop:

		lda	ByteString,y
		cmp	#"0"
		bne	done
		mva	#" " ByteString,y
		iny
		cpy	#2
		bne	zeroloop

done:

		rts
		.endp
		
		Info ConvertByteToDecimalString
				
; Convert (unsigned) word to a string in decimal format, right aligned, leading zeros removed by
; repeated subtraction of powers of 10.
; Note that we can't used MADS macros CPW and SBW here because they don't work when the second parameter is not a constant.
; Also, for performance we want to split the powers of 10 table into two parts for ease of indexing.
; Tested = OK
	
		.proc ConvertWordToDecimalString (.word TempWord) .var
		ldy	#0
		
power10loop:

		ldx	#"0"

; Compare with the current power of 10. If there are no units left, move on to the next power.

countloop:

		lda	TempWord+1
		cmp	Tables.Power10.High,y
		bne	skiplow
		lda	TempWord
		cmp	Tables.Power10.Low,y	

skiplow:

		bcc	nextpower

; Subtract the current power of 10 and increment the count. Then jump back to check for more units.

		sec
		lda	TempWord
		sbc	Tables.Power10.Low,y
		sta	TempWord
		lda	TempWord+1
		sbc	Tables.Power10.High,y
		sta	TempWord+1
		inx
		jmp	countloop

; Store the current digit. We started counting from the character for '0', so this is trivial.

nextpower:

		txa
		sta	WordString,y
		iny	
		cpy	#4
		bne	power10loop

; Finally, whatever is left is the last digit, so just add '0' to this and store it.

		lda	TempWord
		clc
		adc	#"0"
		sta	WordString,y		
		
; Now remove leading zeros, if any. Bail out on first non-zero and don't look at the last digit.

		ldy	#0

zeroloop:

		lda	WordString,y
		cmp	#"0"
		bne	done
		mva	#" " WordString,y
		iny
		cpy	#4
		bne	zeroloop

done:

		rts	
		.endp
		
		Info ConvertWordToDecimalString
				
; Clear values from status panel. This just prints blank spaces over existing values.
; Tested = OK

		.proc ClearStatus
		PrintBlankAt #Constants.PassX #Constants.PassY #.len(WordString)
		PrintBlankAt #Constants.InsertedX #Constants.InsertedY #.len(ByteString)
		PrintBlankAt #Constants.CompleteX #Constants.CompleteY #3
		PrintBlankAt #Constants.ConsistentX #Constants.ConsistentY #3
		PrintBlankAt #Constants.DepthX #Constants.DepthY #.len(ByteString)
		PrintBlankAt #Constants.MemoryX #Constants.MemoryY #.len(WordString)
		PrintBlankAt #Constants.StackX #Constants.StackY #.len(ByteString)
		PrintBlankAt #Constants.TimeX #Constants.TimeY #.len(TimeString)
		rts
		.endp
		
		Info ClearStatus
		
; Display status values. Some if this is really just diagnostic stuff for me and doesn't really benefit the
; end user.
; Tested = OK

		.proc PutStatus

; Print pass

		ConvertWordToDecimalString Pass
		PrintAt #Constants.PassX #Constants.PassY WordString

; Print inserted, making allowance for any guessed values during recursion.

		mva Workspace.Inserted Inserted
		lda Workspace.GuessInserted
		seq:inc Inserted
		mva #0 Workspace.GuessInserted
		ConvertByteToDecimalString Inserted
		PrintAt #Constants.InsertedX #Constants.InsertedY ByteString

; Print complete flag
		
		ldy #0
		PrintYesNoAt "(PComplete),y" #Constants.CompleteX #Constants.CompleteY 

; Print consistent flag

		PrintYesNoAt Workspace.Consistent #Constants.ConsistentX #Constants.ConsistentY	

; Print depth

		ConvertByteToDecimalString Depth
		PrintAt #Constants.DepthX #Constants.DepthY ByteString
		
; Print memory usage. Note this is memory from the start of the program to the end of the puzzle.
; Also update maximum memory usage for later.

		mwa	PValue Memory
		adw	Memory #.len(TPuzzle)
		sbw	Memory #.adr(start)
		cpw Memory MaxMemory
		scc:mwa Memory MaxMemory
		ConvertWordToDecimalString Memory
		PrintAt #Constants.MemoryX #Constants.MemoryY WordString

; Print stack pointer and update minimum stack pointer for later.

		tsx
		stx	TempByte
		lda	MinStack
		cmp TempByte
		scc:mva TempByte MinStack
		ConvertByteToDecimalString TempByte
		PrintAt #Constants.StackX #Constants.StackY ByteString
		
; Print clock (elapsed time).

		PutClock

		rts
		.endp
		
		Info PutStatus
		
; Once the puzzle is complete, show the final status, where Depth is replaced by MaxDepth, for example.
; Tested = OK

		.proc PutFinalStatus
		ConvertByteToDecimalString MaxDepth
		PrintAt #(Constants.DepthX) #Constants.DepthY ByteString 
		ConvertByteToDecimalString MinStack
		PrintAt #Constants.StackX #Constants.StackY ByteString
		ConvertWordToDecimalString MaxMemory
		PrintAt #Constants.MemoryX #Constants.MemoryY WordString
		rts
		.endp
		
		Info PutFinalStatus
		
; Reset clock (well, timer really).
; Tested = OK
		
		.proc ResetClock
		lda #0
		sta RTCLOK
		sta RTCLOK+1
		sta RTCLOK+2
		rts
		.endp
		
		Info ResetClock
				
; Display elapsed time, in 1/10ths of a second.
; Tested = OK

		.proc PutClock
		.var ElapsedTicks .word
		mva RTCLOK+2 ElapsedTicks
		mva RTCLOK+1 ElapsedTicks+1
		ConvertTimeToString ElapsedTicks
		PrintAt #Constants.TimeX #Constants.TimeY TimeString
		rts
		.endp
		
		Info PutClock
		
; Convert elapsed time in frames to string format, showing seconds and tenths of a second.
; Note that this is completed tenths, not nearest. Allowance is made for PAL and NTSC timing
; differences, but only by looking at $D014 (GTIA). So anyone with a hybrid machine might
; see inaccurate timings. Should in theory show time equivalent to running at 100% on an
; emulator when emulator running faster. So, if the solution would take 5 seconds on real
; hardware, the emulator would still show 5 seconds, even though the actual run time would
; be much shorter.
; Tested = OK
		
		.proc ConvertTimeToString (.word TempWord) .var
		lda PAL
		cmp #1
		beq isPAL
		mwa #.adr(Tables.NTSCTicks.Low) P1
		mwa #.adr(Tables.NTSCTicks.High) P2
		jmp skip1
		
isPAL:

		mwa #.adr(Tables.PALTicks.Low) P1
		mwa #.adr(Tables.PALTicks.High) P2
		
skip1:

		ldy	#0
		
power10loop:

		ldx	#"0"

; Compare with the current power of 10. If there are no units left, move on to the next power.
; This needs to be extended for the MSB of RTCLOK, at least in theory, but in this case there is
; no point as the worst case runtime is now ~ 10 seconds. In this case the powers of 10 are
; multiplied by 50 (PAL) or 60 (NTSC) ticks per second. In effect we combine division by 50 or 60
; with conversion to string in one step.

countloop:

		lda	TempWord+1
		cmp	(P2),y
		bne	skiplow
		lda	TempWord
		cmp	(P1),y	

skiplow:

		bcc	nextpower

; Subtract the current power of 10 * ticks and increment the count. Then jump back to check for more units.

		sec
		lda	TempWord
		sbc	(P1),y
		sta	TempWord
		lda	TempWord+1
		sbc	(P2),y
		sta	TempWord+1
		inx
		jmp	countloop

; Store the current digit. We started counting from the character for '0', so this is trivial.
; If this is the tenths of a second, store digit one byte later, to allow space for the '.'

nextpower:

		txa
		cpy #4
		blt regular
		sta TimeString+1,y
		jmp next
		
regular:

		sta	TimeString,y

next:

		iny	
		cpy	#5
		bne	power10loop

; Whatever is left (less than tenths) just gets discarded.
; Just insert the '.'.

		mva #"." TimeString+4
		
; Now remove leading zeros, if any. Bail out on first non-zero and don't look at the last digit
; before the '.'

		ldy	#0

zeroloop:

		lda	TimeString,y
		cmp	#"0"
		bne	done
		mva	#" " TimeString,y
		iny
		cpy	#3
		bne	zeroloop

done:

		rts	
		.endp
		
		Info ConvertTimeToString
		
; Save input buffer to (disk) file.
; Tested = OK

		.proc SaveBuffer
		mva #0 IOStatus
		
; Open file, write access, creating a new file (which will overwrite an existing file with the same name).
 
		ldx	#16
		mva	#CIO.OPEN ICCOM,x
		mva	#CIO.WRITE ICAX1,x	
		mva	#0 ICAX2,x			
		mwa	#.adr(FileName) ICBAL,x
		jsr	CIOV
		
; If open OK, write to file, otherwise store error code.

		bpl write
		sty IOStatus
		jmp close

; Write buffer to open file. Remember to reset X to IOCB * 16 for each CIO call as this gets destroyed.

write:

		ldx #16
		mva #CIO.PUT ICCOM,x
		mwa #.adr(Buffer) ICBAL,x
		mwa #.len(Buffer) ICBLL,x
		jsr CIOV

; Again, store error code if there was a problem.

		bpl close
		sty IOStatus

; Close IOCB (always, even if error on open), but discard error status.

close:

		ldx #16
		mva	#CIO.CLOSE ICCOM,x
		jsr CIOV
		
done:

		rts	
		.endp
		
		Info SaveBuffer
				
; Load input buffer from (disk) file.
; Tested = OK

		.proc LoadBuffer
		mva #0 IOStatus
		
; Open file for reading.

		ldx	#16
		mva	#CIO.OPEN ICCOM,x
		mva	#CIO.READ ICAX1,x
		mva	#0 ICAX2,x		
		mwa	#.adr(FileName) ICBAL,x
		jsr	CIOV
		
; If OK, read from file, otherwise store error code.

		bpl read
		sty IOStatus
		jmp close

; Read buffer from file.

read:

		ldx #16
		mva #CIO.GET ICCOM,x
		mwa #.adr(Buffer) ICBAL,x
		mwa #.len(Buffer) ICBLL,x
		jsr CIOV

; Again, store error code if there was a problem.

		bpl close
		sty IOStatus

; Close IOCB (always, even if error on open), but discard error status.

close:

		ldx #16
		mva	#CIO.CLOSE ICCOM,x
		jsr CIOV
		
done:

		rts	
		.endp		
		
		Info LoadBuffer
		
; Display IO error on screen, if any.
; Tested = OK
		
		.proc ShowIOError

; If there is no error, return.

		lda IOStatus
		bmi showError
		rts

; First show "Error" followed by the actual error number.

showError:

		PrintAt #Constants.ErrorX #Constants.ErrorY Error
		ConvertByteToDecimalString IOStatus
		PrintAt #(Constants.ErrorX+.len(Error)) #Constants.ErrorY ByteString

; Search the error table for the error number, returning the index in Y.
; If no match, also return 0 as this points to generic text.
; Error messages taken from Appendix D of the Atari 130XE Owner's Manual.
; Clearly not all these messages can appear, especially under emulation.
; Note odd MADS syntax for passing Tables.Errors.Length,y to PutString.

		ldy #0

loop:

		lda	Tables.Errors.Number,y
		cmp	IOStatus
		beq found
		iny
		cpy #Constants.NErrors
		bne loop
		ldy #0
		
found:
			
		mva	Tables.Errors.Low,y TempWord
		mva	Tables.Errors.High,y TempWord+1
		mva Tables.Errors.Length,y TempByte
		PrintAt #(Constants.ErrorX+.len(Error)+4) #Constants.ErrorY TempWord TempByte
		rts
		.endp
		
		Info ShowIOError
		
; Clear IO error display by outputting blanks over it.
; Tested = OK
		
		.proc ClearIOError
		PrintBlankAt #Constants.ErrorX #Constants.ErrorY #Constants.Graphics0Columns
		rts
		.endp
		
		Info ClearIOError
				
; Get filename from user via IOCB #0 which defaults to E:
; Tested = OK
		
		.proc GetFileName
		InitialiseCursor
		GotoXY #Constants.InputX #Constants.InputY
		EnableCursor
		ldx #0
		mva	#CIO.GETTEXT ICCOM,x
		mwa #.adr(FileName) ICBAL,x
		mwa #.len(FileName) ICBLL,x
		jsr CIOV
		GotoXY #Constants.InputX #Constants.InputY
		DisableCursor
		
; Paranoia check, ensure last byte is an EOL.

		mva #EOL FileName+.len(FileName)-1
		
; If filename starts with either S or E, then the program will fail as the CIO will interpret these as writes to the S:
; or E: device handlers, which will break the screen display and possibly cause other interesting problems. In these
; cases D: is substituted. 

; First check. If the input starts with S: or E: then change to D:, simply because writing to S: or E: breaks the display.
; Other devices like K:, P:, R: and C: may or may not work, but are less likely to break the program.

		lda FileName+1
		cmp #':'
		bne nextCheck
		lda FileName
		ora #32
		cmp #'s'
		beq fixDevice
		cmp #'e'
		beq fixDevice
		jmp nextCheck
		
fixDevice:

		mva #'D' FileName
		rts
		
; Search for a ":" starting from the second character of the file name. If none found we assume D: required.
; Idea is that the user will enter D1:Filename or D:Filename or D2:Filename.

nextCheck:

		ldy #1

scanLoop:

		lda FileName,y
		cmp #EOL
		beq fix
		cmp #':'
		sne:rts
		iny
		cmp #.len(FileName)
		bne scanLoop		
		
fix:

		ldy #(.len(FileName)-3)
		
loop:
		
		mva	FileName,y FileName+2,y
		dey
		bpl loop
		mva	#'D' FileName
		mva #':' FileName+1
		rts
		.endp
		
		Info GetFileName
		
; Clear panel (2 lines) by outputting blanks over it.
; Tested = OK
		
		.proc ClearPanel
		PrintBlankAt #Constants.PanelX #Constants.PanelY #(Constants.Graphics0Columns*2)
		rts
		.endp
		
		Info ClearPanel
		
; Check if we need to wait for a keypress (that is, we are in single step mode).
; Wait for any key, but if 'r' pressed, turn off single step mode and continue.
; This is because there isn't a clean way to exit from tracing given the way the code
; has been written. So, once you have finished tracing, just press 'r' to let the program
; run on.
; Tested = OK, 26th July 2015
		
		.proc CheckSingleStep
		lda Control.SingleStep
		beq done

; Need to preserve X&Y as code calling this assumes they are unchanged.
; Not really bothered about A though.
; Note that we also need to call PutCells to redraw the screen after each insertion, otherwise
; the user doesn't get to see anything until the pass ends, which is not the intention. This is
; not all that efficient and we could introduce another routine to just put a single cell to the
; screen, but given that PutCells runs faster than the typical user can press keys, is it worth
; the effort?
		
		phr
		PutCells
		GetChar
		ora	#32
		cmp #'r'
		bne cont
		mva #0 Control.SingleStep
		HideTraceMenuItems
cont:
		plr
done:

		rts	
		.endp
		
		Info CheckSingleStep
			
; Initialise screen to graphics 0 by closing and reopening S: on IOCB #6
; CIO errors ignored, this is assumed to always work.
; Tested = OK, 4th October 2015
		
		.proc Graphics0
		ldx #16*6
		mva	#CIO.CLOSE ICCOM,x
		jsr CIOV
		ldx	#16*6
		mva	#CIO.OPEN ICCOM,x
		mva	#CIO.READ+CIO.WRITE ICAX1,x
		mva	#0 ICAX2,x		
		mwa	#.adr(s) ICBAL,x
		jsr	CIOV				
		rts
s:		.byte "S:",0
		.endp
		
		Info Graphics0
		
; Set up checkerboard pattern using players 1 - 3
; This is heavily based on the idea and sample code provided by AtariAge user @PIRX. I have simplified the checkerboard generation code
; and tidied a few things up to fit in with my style, but the code is essentially what @PIRX generously supplied.
; Tested = OK, 4th October 2015
		
		.proc CreatePlayerBackground
		ldx #6*4+2
		ldy #6*4
		lda #%11111100
@:
		sta PLAYER1,x
		sta PLAYER1+12*4,x
		sta PLAYER2+6*4,x
		sta PLAYER3,x
		sta PLAYER3+12*4,x
		inx
		dey
		bne @-

; Set up player/missle graphics as background, 4x width.

		mva #>pmg PMBASE
 		mva #1 GPRIOR
		mva #3 SIZEP1
		sta	SIZEP2
		sta SIZEP3
		
; Set player positions. Player 0 set to position 0 (off screen) as the memory it uses is used for program workspace.
; If you set HPOSP0 to 120 and solve a blank grid, you can see the memory being used.

		mva #0 HPOSP0
		mva #50 HPOSP1
		mva #50+6*4 HPOSP2
		mva #50+12*4 HPOSP3

; Colour. I've gone for a darker shade as lighter shades give poor contrast with text.

		mva #Constants.BackgroundColour PCOLR1
		sta PCOLR2
		sta PCOLR3

; Activate background.

		PlayerBackgroundOn
		rts
		.endp
		
		Info CreatePlayerBackground
		
; Activate players. Split out to provide background toggle feature.
; Tested = OK, 4th October 2015

		.proc PlayerBackgroundOn
 		mva #2 GRACTL 
 		
; Need to update hardward and shadow registers to prevent brief screen corruption. Must be timing related.
; Works fine without DMACTL, but there is some corruption for one frame.

		mva #DMA.EnableDMA+DMA.EnablePlayerDMA+DMA.StandardPlayfield DMACTL
		sta SDMCTL	
		rts
		.endp
		
		Info PlayerBackgroundOn
				
; Remove player/missle background.
; Note also need to zero GRAFPn to avoid full screen height vertical bar appearing.
; Tested = OK, 4th October 2015
		
		.proc PlayerBackgroundOff
		mva #DMA.EnableDMA+DMA.StandardPlayfield SDMCTL
		mva #0 GRACTL
		sta GRAFP0
		sta GRAFP1
		sta GRAFP2
		sta GRAFP3
		rts
		.endp

		Info PlayerBackgroundOff
		