; Using a defined local block like this for each string means we can use the #.len(label) construct to get the length.
; String constants in single quotes are ATASCII characters. Use double quotes for INTERNAL.
; -64 at the end is equivalent to pressing Control for graphics characters.
; +128 at the end gives inverse ATASCII characters.
; MADS seems to do something odd with expressions like "A"-32, or I'm misinterpreting the manual.
; Expressions like 'A'-32 work as described.

; These are mostly INTERNAL characters, but note that ATASCII codes for A-Z are INTERNAL codes for Control+A-Control+Z,
; which is handy for entering line draw characters for the grid.

; Expressions like "A"* adds 128 for inverse video.

Strings	.local

No		.local
		.byte " No"
		.endl

Yes		.local
		.byte "Yes"
		.endl
	
Edit	.local
		.byte "E"*,"dit"
		.endl
		
Exit	.local
		.byte "E"*,"xit"
		.endl
		
On		.local
		.byte " (On)"
		.endl
		
Off		.local
		.byte "(Off)"
		.endl
		
SG1		.local
		.byte 'QRWRWRWRWRWRWRWRWRE'
		.endl
SG2		.local
		.byte '|'," ",'|'," ",'|'," ",'|'," ",'|'," ",'|'," ",'|'," ",'|'," ",'|'," ",'|'
		.endl
SG3		.local
		.byte 'ARSRSRSRSRSRSRSRSRD'
		.endl
SG4		.local
		.byte 'ZRXRXRXRXRXRXRXRXRC'
		.endl
		
		.endl
		
LoadFilePrompt	.local
				.byte "Load puzzle from device:file            "*
				.endl
				
SaveFilePrompt	.local
				.byte "Save puzzle to device:file              "*
				.endl
				
Error			.local
				.byte "Error "
				.endl

Error0			.local
				.byte "Undocumented Error"
				.endl		
				
Error128		.local
				.byte "Break Abort"
				.endl
				
Error129		.local
				.byte "IOCB Already Open"
				.endl				
				
Error130		.local
				.byte "Nonexistent Device"
				.endl
				
Error131		.local
				.byte "IOCB Write-Only Error"
				.endl
				
Error132		.local
				.byte "Invalid Command"
				.endl
				
Error133		.local
				.byte "Device or File Not Open"
				.endl
				
Error134		.local
				.byte "Bad IOCB Number"
				.endl
				
Error135		.local
				.byte "IOCB Read-Only Error"
				.endl
			
Error136		.local
				.byte "EOF (End Of File)"
				.endl
				
Error137		.local
				.byte "Truncated Record"
				.endl
				
Error138		.local
				.byte "Device Time-out"
				.endl
				
Error139		.local
				.byte "Device NAK"
				.endl
				
Error140		.local
				.byte "Serial Bus Input Framing Error"
				.endl
				
Error141		.local
				.byte "Cursor Out of Range"
				.endl
				
Error142		.local
				.byte "Serial Bus Data Frame Overrun"
				.endl
				
Error143		.local
				.byte "Serial Bus Data Frame Checksum"
				.endl
				
Error144		.local
				.byte "Device Done Error"
				.endl
				
Error145		.local
				.byte "Read After Write Compare Error"
				.endl
				
Error146		.local
				.byte "Function Not Implemented"
				.endl
				
Error147		.local
				.byte "Insufficient RAM"
				.endl
				
Error160		.local
				.byte "Drive Number Error"
				.endl
				
Error161		.local
				.byte "Too Many OPEN Files"
				.endl
				
Error162		.local
				.byte "Disk Full"
				.endl
				
Error163		.local
				.byte "Unrecoverable System I/O Error"
				.endl
				
Error164		.local
				.byte "File Number Mismatch"
				.endl
				
Error165		.local
				.byte "File Name Error"
				.endl
				
Error166		.local
				.byte "POINT Data Length Error"
				.endl
				
Error167		.local
				.byte "File Locked"
				.endl
				
Error168		.local
				.byte "Invalid Command"
				.endl
				
Error169		.local
				.byte "Directory Full"
				.endl
				
Error170		.local
				.byte "File Not Found"
				.endl
				
Error171		.local
				.byte "Invalid POINT"
				.endl
				
Error172		.local
				.byte "Illegal Append"
				.endl
				
Error173		.local
				.byte "Bad Sectors at Format Time"
				.endl
		 