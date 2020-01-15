.include "memory.inc"

; nb of bytes to be displayed in DBG_TRACES[0]
.export DBG_TRACE
; bytes to be displayed
.export DBG_TRACES


.CODE
.define STROUT $DB3A ; Applesoft: OUTPUTS AY-POINTED NULL TERMINATED STRING
.define LINPTR $ED24 ; Applesoft: Displays the number A(high)X(low) in decimal

; Traces the number of TRACES requested
DBG_TRACE:
    ldy #>str_trace
    lda #<str_trace
    jsr STROUT
    
    lda #0   
    loop:
        tax
        inx
        txa
        pha
        lda DBG_TRACES, X
        tax
        lda #0
        jsr LINPTR
        
        ldy #>str_space
        lda #<str_space
        jsr STROUT
        
        pla 
        cmp DBG_TRACES        
        bne loop    
    rts

.DATA
str_trace:  .byte     13, "TRACE: ", 0
str_space:  .byte     " ", 0

.BSS
DBG_TRACES: .res 7      ; bytes to be displayed by TRACE



