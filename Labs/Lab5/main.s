;******************** Conner Eckel and Adam Krug *******************************
; @file    main.s
; @author  Conner Eckel and Adam Krug
; @date    October-24-2022
; @note
;           This code is for the EGRE 364 Class at VCU, specifically for lab 4, 
;			which is about working in assembly to run a stepper motor
;*******************************************************************************



;Main Stuff

	INCLUDE core_cm4_constants.s		; Load Constant Definitions
	INCLUDE stm32l476xx_constants.s      

	AREA    main, CODE, READONLY
	EXPORT	__main				; make __main visible to linker
	ENTRY		

;E12 Controls A
;E13 Controls C
;E14 Controls B
;E15 Controls D


__main	PROC	

wavestep EQU 0x84218421
fullstep EQU 0xC639C639
halfstep EQU 0x8C462319

	BL initAPort
	BL initEPort
	MOV r7, #0x10000
	LDR r2, =fullstep
	ROR r2, #16
	MOV r5, #0x0
mainloop

	BL dostep
	BL dostep
	BL dostep
	BL dostep
	
	B mainloop



	

stop 	B 		stop     		; dead loop & program hangs here

;end stuff
	ENDP
		
;********************* InitAPort *************************************
;	No Inputs
;	No Outputs
;	Initializes Pins 3 and 5 of Port A to be used as input. These are
;	Up and down on the joystick respectively
;*********************************************************************		
initAPort PROC
	PUSH{r0,r1,r2, r3}						;Stacking original value in registers

	; Enable the clock to GPIO Port A	
	LDR r0, =RCC_BASE   				; Stores base clock address in r0
	LDR r1, [r0, #RCC_AHB2ENR]			; Stores the clock enable register in r1;
	ORR r1, r1, #RCC_AHB2ENR_GPIOAEN	; Enables Clock
	STR r1, [r0, #RCC_AHB2ENR]			; Stores data back to memory
	
	
	LDR R1, [R0,#GPIO_OSPEEDR]
	LDR R2, =0x0FF
	ORR R1, R1, R2, LSL #24
	STR R1, [R0,#GPIO_OSPEEDR]

	; Mode Register Port A
	LDR r0, =GPIOA_BASE 				; Stores the port A base address in r0
	LDR r1, [r0, #GPIO_MODER]			; Stores the contents of the GPIOA MODER in r1
	MOV r2, #0xFFC					; Buffering mask into r2, 0xCC0 Clears pins 3 and 5 and 0
	BIC r1, r1,  r2						; MODER 2 bits wide so this clears pin 3 of the mode register (3*2)
	;                                	; No ORR necessary since input needs to be 00 anyways
	STR r1, [r0, #GPIO_MODER]			; This stores it back to memory

	; PUPDR port A
	LDR r0, =GPIOA_BASE					; Stores the port A base address in r0
	LDR r1, [r0, #GPIO_PUPDR]			; Stores the base address for pupdr register in r1
	LDR r3, =0xFFC
	BIC r1, r1, r3						; Clears pin 3 and pin 5
	LDR r3, =0xAA8
	ORR r1, r1, r3				; Sets pin 3 and pin 5 and 0 to pull down
	STR r1, [r0, #GPIO_PUPDR]			; Stores back to memory

	POP{r0,r1,r2, r3}						;Popping original value in registers
	BX LR
	ENDP


;********************* InitEPort *************************************
;	No Inputs
;	No Outputs
;	Initializes Pins 12-15 of Port E to be used as output, configured
;   as Push-Pull, No Pull-Up No Pull-Down, with space to configure OSPEEDR
;*********************************************************************
initEPort PROC
	PUSH{r0,r1,r2}

	; Enable the clock to GPIO Port E	
	LDR r0, =RCC_BASE   				; Stores base clock address in r0
	LDR r1, [r0, #RCC_AHB2ENR]			; Stores the clock enable register in r1;
	ORR r1, r1, #RCC_AHB2ENR_GPIOEEN	; Enables Clock
	STR r1, [r0, #RCC_AHB2ENR]			; Stores data back to memory

	; Mode Register Port E
	LDR r0, =GPIOE_BASE 				; Stores the port E base address in r0
	LDR r1, [r0, #GPIO_MODER]			; Stores the base address for mode register in r1
	LDR r2, =0xFF000000					; Buffering into r2
	BIC r1, r1,  r2						; MODER 2 bits wide so this clears pin 12-15 of the mode register (10*2)
	LDR r2, =0x55000000					; Buffering into r2
	ORR r1, r1,  r2						; this sets pin12-15 of the mode register to 01, which is output (10*2)
	STR r1, [r0, #GPIO_MODER]			; This stores it back to memory

	; OTyper port E
	LDR r0, =GPIOE_BASE					; Stores the port E base address in r0
	LDR r1, [r0, #GPIO_OTYPER]			; Stores the base address for otyper register in r1
	LDR r2, =0xFF000000					; Buffering into r2
	BIC r1, r1, r2						; Clears pins 12-15, no setting necessary since it's push-pull
	STR r1, [r0, #GPIO_OTYPER]			; This stores it back to memory

	; PUPDR port E
	LDR r0, =GPIOE_BASE					; Stores the port E base address in r0
	LDR r1, [r0, #GPIO_PUPDR]			; Stores the base address for pupdr register in r1
	LDR r2, =0xFF000000					; Buffering into r2
	BIC r1, r1, r2						; Clears pins e12-e15
	STR r1, [r0, #GPIO_PUPDR]			; Stores back to memory

	POP{r0,r1,r2}
	BX LR
	ENDP

;********************* Delay *************************************
;	No Inputs
;	No Outputs
;	Time wasting function, rather than working with STK library
;*********************************************************************
delay PROC 
	;Delay function from lecture
	PUSH{LR}
	PUSH {r0, r1, r2, r3}
	LDR r0, =GPIOA_BASE
	LDR r3, =0xFFFFFFFF
	EOR r3, r3, #0x28
	MOV r1, r7   ;initial value for loop counter
again  NOP  ;execute two no-operation instructions
	NOP
	LDR r2, [r0, #GPIO_IDR]
	BIC r2, r2, r3
	CMP r2, #0x00
	MOVEQ r5, #(0x00)
	CMP r1, #0x00
	BEQ finish
	SUBS r1, #1
	BNE again
finish 
	POP {r0, r1, r2, r3}
	POP{LR}
	BX LR
	ENDP
;********************* Base Delay ************************************
;	No Inputs
;	No Outputs
;	Time wasting function, rather than working with STK library
;*********************************************************************
basedelay PROC 
	;Delay function from lecture
	PUSH{LR}
	PUSH {r0, r1, r2, r3}
	LDR r0, =GPIOA_BASE
	LDR r3, =0xFFFFFFFF
	EOR r3, r3, #0x28
	MOV r1, #1000   ;initial value for loop counter
baseagain  NOP  ;execute two no-operation instructions
	NOP
	LDR r2, [r0, #GPIO_IDR]
	BIC r2, r2, r3
	CMP r2, #0x00
	MOVEQ r5, #(0x00)
	SUBS r1, #1
	BNE baseagain ;
	POP {r0, r1, r2, r3}
	pop{LR}
	BX LR
	ENDP
;********************* StepPart ************************************
;	No Inputs
;	No Outputs
;	
;*********************************************************************
steppart PROC
	push{LR}
	push{r5}
	LDR r3, =0xFFFF0FFF
	LDR r0, =GPIOE_BASE
	LDR r1, [r0, #GPIO_ODR]
	BIC r5, r2, r3
	ORR r1, r1, r5
	STR r5, [r0, #GPIO_ODR]
	ROR r2, #28
	pop{r5}
	pop{LR}
	BX LR
	ENDP
		
input PROC
		;Function to read the input from the joystick
		;Input in C
			;while (1){
				;uint32_t data = GPIOA->IDR;
				;if ((data & (0x1 << 3))){
				;	return 1;
				;}
				;else if ((data & (0x01 << 5))){
				;	return -1;
				;}
			;}
		
		push{LR}
		push{r1,r2}
		LDR r0, =GPIOA_BASE
		LDR r2, =0xFFFFFFFF
		EOR r2, r2, #0x2E
		LDR r1, [r0, #GPIO_IDR]
		BIC r1, r1, r2
		CMP r1, #0x08
		BEQ branch1
		CMP r1, #0x20
		BEQ branch2
		CMP r1, #0x02
		BEQ branch3
		CMP r1, #0x04
		BEQ branch4
		MOV r6, #0x02
		pop{r1, r2}
		pop{LR}
		BX LR

branch1
		LDR r6, =0x0
		MOV r5, #0x01
		pop{r1, r2}
		pop{LR}
		BX LR
branch2
		
		LDR r6, =0x1
		MOV r5, #0x01
		pop{r1, r2}
		pop{LR}
		BX LR
		
branch3
		pop{r1, r2}
		pop{LR}
		LDR r2, =halfstep
		BX LR
branch4
		pop{r1, r2}
		pop{LR}
		LDR r2, =fullstep
		BX LR

		
		ENDP
dostep PROC
	push{LR}
	CMP r5, #(0x01)
	BEQ contstep
	BL input
	CMP r6, #(0x00)
	BEQ maxspeed
	CMP r6, #(0x01)
	BEQ minspeed
contstep
	BL steppart
	BL basedelay
	BL delay
	MOV r6, #0x02
	pop{LR}
	BX LR

	ENDP
		
maxspeed
	CMP r7, #(0x01)
	MOVNE r7, r7, LSR #1
	B contstep
minspeed
	CMP r7, #(0x10000000)
	MOVNE r7, r7, LSL #1
	B contstep

	ALIGN			
	AREA    myData, DATA, READWRITE
	ALIGN
	END