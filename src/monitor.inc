; Copyright (C) 2018 Christophe Meneboeuf <christophe@xtof.info>
;
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program. If not, see <http://www.gnu.org/licenses/>.


; ******************************************************
; This file contains aliases for Montitor's and Applesoft's routines
; ******************************************************

; ++++ ZERO PAGE ++++

.define WNDLFT	 $20	    ; $20 Left edge of text window
.define WNDWDTH	 WNDLFT+1	; $21 Width of text window
.define WNDTOP	 WNDWDTH+1	; $22 Top of text window
.define WNDBTM	 WNDTOP+1	; $23 Bottom+1 of text window
.define CH	     WNDBTM+1	; $24 Cursor horizontal position
.define CV	     CH+1	    ; $25 Cursor vertical position
.define BASL	 $28	    ; $28 Text base address
.define BASH	 BASL+1	    ; $29
.define INVFLG	 $32	    ; $32 Normal/Inverse/Flash
.define PROMPT	 INVFLG+1	; $33 Prompt character
.define CSWL	 $36	    ; $36 Character output hook
.define CSWH	 CSWL+1	    ; $37
.define KSWL	 CSWH+1	    ; $38 Character input hook
.define KSWH	 KSWL+1	    ; $39


; ++++ Monitor ++++

.define INIT	 $fb2f	; Initialize text screen
.define SETTXT	 $fb39	; Set text mode
.define SETWND	 $fb4b	; Set text window size
.define SETWND2	 $fb51	; Set text window width and bottom size
.define TABV	 $fb5b	; Vertical tab
.define BASCALC	 $fbc1	; Text base-address calculator
.define STORADV	 $fbf0	; Place a printable character on the screen
.define ADVANCE	 $fbf4	; Increment the cursor position
.define VIDOUT	 $fbfd	; Place a character on the screen
.define VTAB	 $fc22	; Vertical tab
.define VTABZ	 $fc24	; Vertical tab (alternate entry)
.define HOME	 $fc58	; Home cursor and clear to end of page
.define RDKEY	 $fd0c	; Get an input character
.define CROUT	 $fd8e	; Issue a carriage return
.define PRBYTE	 $fdda	; Print a hexadecimal byte
.define COUT	 $fded	; Output a character
.define COUT1	 $fdf0	; Output a character to the screen
.define SETINV	 $fe80	; Set inverse text mode
.define SETNORM	 $fe84	; Set normal text mode
.define SETKBD	 $fe89	; Reset input to keyboard
.define SETVID	 $fe93	; Reset output to screen


; ++++ HIRES GFX ++++

; Colors
; SET #1
.define BLACK1  $0
.define GREEN   $1
.define VIOLET  $2
.define WHITE1  $3
; SET #2
.define BLACK2  $4
.define ORANGE  $5
.define BLUE    $6
.define WHITE2  $7

.define HGR     $F3E2
; Initializes to hi-res page 1, clears screen.

.define HGR2    $F3D8
; Initializes to hi-res page 2, clears screen.

.define HCLR    $F3F2
; Clears current screen to black1.

.define BKGND   $F3F6
; Clears current screen to last plotted HCOLOR.

.define HCOLOR  $F6F0
; Sets HCOLOR to contents of X-Register (0−7).

.define HPOSN   $F411
; Positions hi-res “cursor” without plotting. Enter with
; X, Y (low, high) = horizontal position, Accumulator =
; vertical position.

.define HPLOT   $F457
; Identical to HPOSN, but plots current HCOLOR at coordinates
; given.

.define HFIND   $F5CB
; Returns current “cursor” position. Useful after aDRAW
; to find where you’ve been left. Coordinates returned in:
; $E0, $E1 = horizontal (low,high), $E2 = vertical.

.define HLIN    $F53A
; Draws a line from last plot to point given. Accumulator,
; X (low, high) = horizontal, Y = vertical position.

.define SHNUM   $F730
; Puts address of shape number indicated by X-Register
; into$1A,$1B; returns with X, Y (low, high) also set to
; address of that shape-table entry.

.define DRAW    $F601
; Draw shape pointed to by X, Y (low, high) in current
; HCOLOR. Note: X, Y point to specific entry,not the
; beginning of the table. Call SHNUM first

.define XDRAW   $F65D
; Erases shape just drawn (if there) by doing anexclusive
; OR with the screen data. Load X, Y (low, high) with
; address of shape toXDRAW or callSHNUM first with XRegister
; = shape numbe


; *********** STRINGS *************

.define GETSPACE $E452
; Reduces the start-of-strings
; pointer, FRETOP ($6F), by the
; number specified in the A-register
; (the string length) and sets up
; FRESPC ($71) so that it equals
; FRETOP. After this has been done,
; A remains unaffected and Y (high)
; and X (low) point to the beginning
; of the space. The string can
; then be moved into place in upper
; memory by using MOVESTR.


.define GARBAGE $E484
; Clears out old string definitions
; that are no longer being used and
; adjusts FRETOP {$6F) accordingly.
; (Each time that a string is
; redefined, its old definition is kept
; in memory but is not used.) This
; process is called "garbage collection"
; and is performed automatically
; whenever the start-ofstrings
; address, FRETOP, comes
; close to the end-of-variables address,
; STREND {$6D).


.define MOVESTR $E5E2
; Copies the string that is pointed
; to by Y (high) and X (low) and
; that has a length of A to the location
; pointed to by FRESPC
; ($71).


.define FOUT $ED34
; Converts the FAC into an ASCII
; character string that represents
; the number in decimal form (like
; Applesoft's STR$ function). The
; string is followed by a $00 byte
; and is pointed to by Y (high) and
; A (low) so that STROUT can be
; used to print the string.


.define STROUT $DB3A
; Prints the string pointed to by Y
; (high) and A (low). The string must
; be followed immediately by a $00
; or a $22 byte. All of these conditions
; are set up by FOUT.


.define STRPRT $DB3D
; Prints the string whose 3-byte descriptor
; is pointed to by $A0/$A1.
; FRMEVL sets up such a pointer
; when calculating string formulas.
