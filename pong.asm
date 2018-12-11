;;Simple Pong program.
;;By Lawrie Griffiths

    processor 6502
    include "vcs.h"
    include "macro.h"
	
    seg.u vars
    org $80
	
Ball_X  DS 1
Ball_Y  DS 1
Bat0_Y  DS 1
Bat0_E  DS 1
Bat1_Y  DS 1
Bat1_E  DS 1
Ball_H  DS 1
Ball_V  DS 1

    seg Code
    org $F000		
	
Start:
    LDX #0            ; Clear RAM and TIA and set Stack Pointer
    TXA  
    
Clear:
    DEX
    TXS
    PHA
    BNE Clear
    
    LDA #$00          ; Set colours
    STA COLUPF
    LDA #$5A
    STA COLUBK
    LDA #$0E
    STA COLUP0
	STA COLUP1
    
    LDA #$E0          ; Move Ball 2 right, gets done 37 times
    STA HMBL          ; So ball X position becomes 74
    LDA #$F0          ; Move missile 0 1 right so it gets set to 37
    STA HMM0
	LDA #$C0
	STA HMM1
    
	LDA #80
	STA Bat0_Y
	CLC
	ADC #40
    STA Bat0_E
    
    LDA #80
	STA Bat1_Y
	CLC
	ADC #40
    STA Bat1_E
    
	LDA #80
	STA Ball_Y

    lda #6
    sta AUDC0
    sta AUDF0
	
    LDA #2            ; Start VBLANK
    STA VBLANK
    
Frame:
    LDA #2
    
Vsync0:
    STA VSYNC         ; 3 VSYNC lines
    STA WSYNC
    STA WSYNC
    STA WSYNC
    LDA #0
    STA VSYNC
    LDY #37           ; 37 VBLANK lines
    
Vblank0:
    STA WSYNC
	CPY #30           ; Just 7 times for left bat
	BPL Cont_M0
	LDA #0
	STA HMM0
    
Cont_M0:
    STA HMOVE         ; Move ball and missiles
    DEY
    BNE Vblank0
    
    LDA #0            ; Clear VBLANK
    STA VBLANK
    STA HMCLR         ; Clear Ball and missile movement
    LDY #0            ; Count picture lines
    
Picture:
    LDA #0
    CPY Ball_Y
    BNE NoBall
    LDA #2
    
NoBall:
    STA ENABL
    
    LDA #0
    CPY Bat0_Y
    BMI NoBat
    CPY Bat0_E
    BPL NoBat
    LDA #2
    
NoBat:
    STA ENAM0 
    
    LDA #0
    CPY Bat1_Y
    BMI NoBat1
    CPY Bat1_E
    BPL NoBat1
    LDA #2 

NoBat1:    
	STA ENAM1
    
    INY
    STA WSYNC
    CPY #192
    BNE Picture
    
    LDA #2            ; Set VBLANK
    STA VBLANK

	LDY Bat0_Y
	LDA SWCHA         ;get both sticks
	ASL               ;slide off up bit
	ASL
	ASL
    BCS Not_Up
        CPY #151
        BPL Not_Up
    INY
    INY
 
Not_Up:
   	ASL               ;slide off down bit
	BCS Not_Down      ;skip if set
        CPY #2
        BMI Not_Down
	DEY               ;...or, bump y
	DEY
    
Not_Down:
    TYA
    STA Bat0_Y
    CLC
    ADC #40
    STA Bat0_E
    
    LDA SWCHA
    LDY Bat1_Y
    ASL
    ASL
    ASL
    ASL
    ASL
    ASL
    ASL
	BCS Not_Up1        ;skip if set
    CPY #151
    BPL Not_Up1
	INY               ;...or, bump Y
	INY
    
Not_Up1:
        CPY #2
        BMI Not_Down1
   	ASL               ;slide off down bit
	BCS Not_Down1     ;skip if set
	DEY               ;...or, bump y
	DEY
    
Not_Down1:
    TYA
    STA Bat1_Y
	CLC
	ADC #40
	STA Bat1_E
	
    LDA Ball_V        ; Ball Vertical direction
	BNE Ball_Up
	INC Ball_Y
	.byte $2C         ; Skip instruction
    
Ball_Up:
    DEC Ball_Y
    
    LDA Ball_Y
    BNE Not_Top
    STA Ball_V        ; Store 0
    JMP Horiz
    
Not_Top:
     CMP #191
     BNE Horiz
     LDA #1
     STA Ball_V
   
Horiz:   
        LDA #0
        STA AUDV0
	LDA Ball_H
	BNE Ball_Left
	LDA #$F0
	JMP Set_Ball
    
Ball_Left
	LDA #$10
    
Set_Ball:
    STA HMBL
	STA WSYNC
	STA HMOVE
	
	LDA CXM1FB
	ASL
	ASL
	BCC No_Change
	LDA Ball_H
	LDA #1
	STA Ball_H
        STA AUDV0
    
No_Change:
    LDA CXM0FB
    ASL
    ASL
    BCC No_Change1
    LDA #0
    STA Ball_H
    LDA #1
    STA AUDV0
    
No_Change1:
	
    LDY #29           ; Another 29 Overscan lines
Overscan:
    DEY
    STA WSYNC
	STA HMCLR
	STA CXCLR
    BNE Overscan
    JMP Frame
		
    echo "----",($FFFC - *) ," bytes left"
	
    org $FFFC
    .word Start
    .word Start
