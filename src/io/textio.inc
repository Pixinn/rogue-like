.import Print
.import ClearTxt
.import Cin_Str
.import Cin_Char

.import CIN_STR


; --- string with high-bit set, null-terminated
; Apple II char < 128 are inverted
.macro ASCIIZ str
.repeat .strlen (str), c
.byte .strat (str, c) | $80
.endrep
.byte 0
.endmacro


.macro PRINT string
    lda #>string
    ldx #<string
    jsr Print
.endmacro
