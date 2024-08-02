; TODO INSERT CONFIG CODE HERE USING CONFIG BITS GENERATOR
#INCLUDE <P18F4550.INC>
COUNT1  EQU	0X07
COUNT2  EQU	0X06
HP_H	EQU	0X04
GROWTH	EQU	0X05
HP_L	EQU	0X03
WATER	EQU	0X02
LD  EQU PORTD
LC  EQU PORTC
RS  EQU RC5
RW	EQU RC1
EN	EQU RC2

RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    INT               ; go to beginning of program

; TODO ADD INTERRUPTS HERE IF USED
    ORG 0X008
    MOVLB   0X00
    CALL U_U
    CALL CHK
    RETFIE
CHK ORG	0100H
        ; BTFSC   PIR1,TMR1IF
    ;GOTO    T1_INT
    BTFSC   INTCON,INT0IF
    GOTO    HP_INT
    BTFSC   INTCON3,INT1IF
    GOTO    SUNNY
    RETURN
SUNNY	CALL	U_U
	MOVLW	0XC4
	CALL	CW
	CALL	U_U
	BTFSC	PORTB,1
	GOTO	YE
	MOVLW	'N'
	CALL	DSEND
	CALL	U_U
FIN	BCF	INTCON3,INT1IF
	RETURN
YE	MOVLW	'Y'
	CALL	DSEND
	CALL	U_U
	GOTO	FIN	
HP_INT	ORG 0200H
	MOVLW	0X05
	MOVWF	WATER
	CALL	WATERING
AGAIN	MOVLW	0X38
	CPFSLT	HP_L
	GOTO	HI
	INCF	HP_L,F
HERE	DECF	WATER
	BNZ	AGAIN
	CALL	SET_HP
	BCF	INTCON,INT0IF
	CALL	CLEAR_WAT
	RETFIE
HI	
	CPFSGT	HP_H
	GOTO	GOGO
	GOTO	HERE
GOGO	INCF	HP_H,F
	MOVLW	0X30
	MOVWF	HP_L
	GOTO	HERE
CLEAR_WAT
	CALL	U_U
	MOVLW	0X8B	
	CALL	CW
	CALL	U_U
	MOVLW	0X00
	CALL	DSEND
	CALL	U_U
	MOVLW	0X00
	CALL	DSEND
	CALL	U_U
	MOVLW	0X00
	CALL	DSEND
	CALL	U_U
	MOVLW	0X00
	CALL	DSEND
	CALL	U_U
	MOVLW	0X00
	CALL	DSEND
	CALL	U_U
	MOVLW	0XCC	
	CALL	CW
	CALL	U_U
	MOVLW	0X00
	CALL	DSEND
	CALL	U_U
	MOVLW	0X00
	CALL	DSEND
	CALL	U_U
	MOVLW	0X00
	CALL	DSEND
	CALL	U_U
	RETURN
	
WATERING
	CALL	U_U
	MOVLW	0X8B	
	CALL	CW
	CALL	U_U
	MOVLW	'W'
	CALL	DSEND
	CALL	U_U
	MOVLW	'A'
	CALL	DSEND
	CALL	U_U
	MOVLW	'T'
	CALL	DSEND
	CALL	U_U
	MOVLW	'E'
	CALL	DSEND
	CALL	U_U
	MOVLW	'R'
	CALL	DSEND
	CALL	U_U
	MOVLW	0XCC	
	CALL	CW
	CALL	U_U
	MOVLW	'I'
	CALL	DSEND
	CALL	U_U
	MOVLW	'N'
	CALL	DSEND
	CALL	U_U
	MOVLW	'G'
	CALL	DSEND
	CALL	U_U
	RETURN

SET_HP	ORG 0350H
	CALL	U_U
	MOVLW	0X83	
	CALL	CW
	CALL	U_U
	MOVF	HP_H,W
	CALL	DSEND
	CALL	U_U
	MOVF	HP_L,W
	CALL	DSEND
	CALL	U_U
	RETURN
D_HP	ORG 0600H

	MOVLW	0X30
	CPFSGT	HP_L
	GOTO	CHG_HP_H
	DECF	HP_L,F
	CALL	SET_HP
	RETURN
CHG_HP_H    
	    MOVLW   0X30
	    CPFSGT  HP_H
	    CALL    HP_L_CHK
	    DECF    HP_H,F
	    MOVLW   0X39
	    MOVWF   HP_L
	    CALL    SET_HP
	    RETURN
HP_L_CHK    MOVLW   0X30
	    CPFSGT  HP_L
	    CALL   GAME_OVER
	    CALL    SET_HP
	    RETURN
GAME_OVER  
	    MOVLW   0X87
	    CALL    CW
	    CALL    U_U
	    MOVLW   'G'
	    CALL    DSEND
	    CALL    U_U
	    MOVLW   'A'
	    CALL    DSEND
	    CALL    U_U
	    MOVLW   'M'
	    CALL    DSEND
	    CALL    U_U
	    MOVLW   'E'
	    CALL    DSEND
	    CALL    U_U
	    MOVLW   0XC7
	    CALL    CW
	    CALL    U_U
	    MOVLW   'O'
	    CALL    DSEND
	    CALL    U_U
	    MOVLW   'V'
	    CALL    DSEND
	    CALL    U_U
	    MOVLW   'E'
	    CALL    DSEND
	    CALL    U_U
	    MOVLW   'R'
	    CALL    DSEND
	    CALL    U_U
	    GOTO    $
	    RETURN
LDELAY
    MOVLW   D'250'
    MOVWF   COUNT1
D1  MOVLW   D'250'
    MOVWF   COUNT2
D2  NOP
    NOP
    DECF    COUNT2,F
    BNZ	D2
    DECF    COUNT1,F
    BNZ	D1
    RETURN
CW
    MOVWF   LD	
    BCF	    LC,RS
    BCF	    LC,RW
    BSF	    LC,EN
    CALL    SDELAY 
    BCF	    LC,EN
    RETURN

DSEND
    MOVWF   LD
    BSF	    LC,RS
    BCF	    LC,RW
    BSF	    LC,EN
    CALL    SDELAY 
    BCF	    LC,EN
    RETURN
  
U_U
    SETF    TRISD
    BCF	    LC,RS
    BSF	    LC,RW
BACK
    BSF	    LC,EN
    CALL    SDELAY
    BCF	    LC,EN
    BTFSC   LD,7
    BRA	    BACK
    CLRF    TRISD
    RETURN


SDELAY
    MOVLW   D'200'
    MOVWF   COUNT1
D3  MOVLW   D'250'
    MOVWF   COUNT2
D4  NOP
    NOP
    DECF    COUNT2,F
    BNZ	D2
    DECF    COUNT1,F
    BNZ	D1
    RETURN    
;Setup LCD AND INTERRUPTS       
INT ORG 0X0800
	MOVLW	0X0F
	MOVWF	ADCON1
	MOVLW	0X39
	MOVWF	HP_H
	MOVLW	0X39
	MOVWF	HP_L
	BSF	INTCON,INT0IE
	BCF	INTCON,INT0IF
	BSF	INTCON3,INT1IE
	BCF	INTCON2,INTEDG1
	MOVLW	0X34
	MOVWF	T1CON
	BCF	PIR1,TMR1IF
	;TMR1 SETUP
	MOVLW	0X0E
	MOVWF	GROWTH
	;Timer 0 setup
	CLRF	TRISD
	CLRF	TRISC
	SETF	TRISB
	BCF	LC,EN
	CALL	LDELAY
	MOVLW	0X38		;LINE SETUP
	CALL	CW
	CALL	LDELAY
	MOVLW	0X0E	;DISPLAY ON, CRUSOR OFF
	CALL	CW
	CALL	U_U
	MOVLW	0X01	;CLEAR SCREEN
	CALL	CW
	CALL	U_U
	GOTO	BASIC	
BASIC
	MOVLW	0X89	
	CALL	CW
	CALL	U_U
	MOVLW	0xD5
	CALL	DSEND
	CALL	U_U
	MOVLW	0XC9	
	CALL	CW
	CALL	U_U
	MOVLW	0xFF
	CALL	DSEND
	CALL	U_U
	MOVLW	0X80	
	CALL	CW
	CALL	U_U
	MOVLW	'H'
	CALL	DSEND
	CALL	U_U
	MOVLW	'P'
	CALL	DSEND
	CALL	U_U
	MOVLW	':'
	CALL	DSEND
	CALL	U_U
	CALL	SET_HP
	MOVLW	'%'
	CALL	DSEND
	CALL	U_U
	MOVLW	0XC0	
	CALL	CW
	CALL	U_U
	MOVLW	'S'
	CALL	DSEND
	CALL	U_U
	MOVLW	'U'
	CALL	DSEND
	CALL	U_U
	MOVLW	'N'
	CALL	DSEND
	CALL	U_U
	MOVLW	':'
	CALL	DSEND
	CALL	U_U
	CALL	SUN_INT
	
	GOTO	START
SUN_INT

	CALL	U_U
	MOVLW	0XC4
	CALL	CW
	CALL	U_U
	BTFSC	PORTB,1
	GOTO	YEE
	MOVLW	'N'
	CALL	DSEND
	CALL	U_U
	CALL	D_HP
FINN	RETURN
YEE	MOVLW	'Y'
	CALL	DSEND
	CALL	U_U
	GOTO	FINN
GROW	BSF TRISB,6
	BSF PORTB,6
	MOVLW	0X89	
	CALL	CW
	CALL	U_U
	MOVLW	0xCE
	CALL	DSEND
	CALL	U_U
	BCF	T0CON,TMR0ON
JOJO	BCF	INTCON,TMR0IF
	RETURN
MAIN_PROG CODE                      ; let linker place main program
START
    BCF	    INTCON,TMR0IF
    BSF	    T0CON,TMR0ON
    BSF	INTCON,GIE

DIO_DESU     
	CALL	SUN_INT   
	MOVLW	0X0B
	MOVWF	TMR1H
	MOVLW	0XDC
	MOVWF	TMR1L
	BCF	PIR1,TMR1IF
	BSF	T1CON,TMR1ON
MUDA	BTFSS	PIR1,TMR1IF
	GOTO	MUDA
	CALL	D_HP
	BCF	PIR1,TMR1IF
	DCFSNZ	GROWTH
	CALL	GROW
	GOTO	DIO_DESU
    END