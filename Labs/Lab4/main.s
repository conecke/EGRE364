;******************** Conner Eckel and Adam Krug *******************************************
; @file    main.s
; @author  Conner Eckel and Adam Krug
; @date    October-24-2022
; @note
;           This code is for the EGRE 364 Class at VCU, specifically for lab 4, which is
;			about working in assembly to enable an updown counter
;*******************************************************************************

	INCLUDE core_cm4_constants.s		; Load Constant Definitions
	INCLUDE stm32l476xx_constants.s      

	AREA    main, CODE, READONLY
	EXPORT	__main				; make __main visible to linker
	ENTRY			
SysTick_Handler PROC
	export SysTick_Handler
	ADD r5, #0x1
	BX LR
	ENDP

			
__main	PROC	


;Register usage:
	; r0 - Stores base address for Port or Clock
	; r1 - Stores base address for specific register or clock port
	; r2 - Used as a buffer for instructions
	; r3 - reserved
	; r4 - delay value
	; r5 - used for the delay function
	; r6 - stores the value of the input
	; r7 - stores the mask for which LED segments should be turned on

;Segment Pattern initialization	
digit0 EQU 0x3F
digit1 EQU 0x06
digit2 EQU 0x5B 
digit3 EQU 0x4F 
digit4 EQU 0x66
digit5 EQU 0x6D 
digit6 EQU 0x7D 
digit7 EQU 0x07 
digit8 EQU 0x7F
digit9 EQU 0x6F

STK_BASE EQU (0xE000E010)
STK_CTRL EQU 0x00
STK_LOAD EQU 0x04
STK_VAL EQU 0x08
STK_CALIB EQU 0x0C


;Example Code for Clock from template
    ;Enable the clock to GPIO Port B	
	;LDR r0, =RCC_BASE   				; Stores base clock address in r0
	;LDR r1, [r0, #RCC_AHB2ENR]			; Stores the clock enable register in r1;
	;ORR r1, r1, #RCC_AHB2ENR_GPIOBEN	; Enables Clock
	;STR r1, [r0, #RCC_AHB2ENR]			; Stores data back to memory


;Clock Setup
	;System clock setup in C
	;	// Enable High Speed Internal Clock (HSI = 16 MHz)
	;	RCC->CR |= ((uint32_t)RCC_CR_HSION);

	;	// wait until HSI is ready
	;	while ( (RCC->CR & (uint32_t) RCC_CR_HSIRDY) == 0 ) {;}

	;	// Select HSI as system clock source
	;	RCC->CFGR &= (uint32_t)((uint32_t)~(RCC_CFGR_SW));
	;	RCC->CFGR |= (uint32_t)RCC_CFGR_SW_HSI;  //01: HSI16 oscillator used as system clock

	;	// Wait till HSI is used as system clock source
	;	while ((RCC->CFGR & (uint32_t)RCC_CFGR_SWS) == 0 ) {;}
	; Enable GPIO clock
	LDR		R1, =RCC_AHB1ENR	;Pseudo-load address in R1
	LDR		R0, [R1]			;Copy contents at address in R1 to R0
	ORR.W 	R0, #0x08			;Bitwise OR entire word in R0, result in R0
	STR		R0, [R1]			;Store R0 contents to address in R1

	; Enable the clock to GPIO Port A	
	LDR r0, =RCC_BASE   				; Stores base clock address in r0
	LDR r1, [r0, #RCC_AHB2ENR]			; Stores the clock enable register in r1;
	ORR r1, r1, #RCC_AHB2ENR_GPIOAEN	; Enables Clock
	STR r1, [r0, #RCC_AHB2ENR]			; Stores data back to memory

	; Enable the clock to GPIO Port E	
	LDR r0, =RCC_BASE   				; Stores base clock address in r0
	LDR r1, [r0, #RCC_AHB2ENR]			; Stores the clock enable register in r1;
	ORR r1, r1, #RCC_AHB2ENR_GPIOEEN	; Enables Clock
	STR r1, [r0, #RCC_AHB2ENR]			; Stores data back to memory

	; Enable the clock to GPIO Port H	
	LDR r0, =RCC_BASE   				; Stores base clock address in r0
	LDR r1, [r0, #RCC_AHB2ENR]			; Stores the clock enable register in r1;
	ORR r1, r1, #RCC_AHB2ENR_GPIOHEN	; Enables Clock
	STR r1, [r0, #RCC_AHB2ENR]			; Stores data back to memory

	
;Example Code from template to set up the ports as the correct state

	; MODE: 00: Input mode, 01: General purpose output mode
    ;       10: Alternate function mode, 11: Analog mode (reset state)

	;LDR r0, =GPIOB_BASE 				; Stores the port B base address in r0

	; Mode Register
	;LDR r1, [r0, #GPIO_MODER]			; Stores the base address for mode register in r1
	;BIC r1, r1,  #(0x3<<4)				; MODER 2 bits wide so this clears pin 2 of the mode register
	;ORR r1, r1,  #(0x1<<4)				; this sets pin2 of the mode register to 01, which is output
	;STR r1, [r0, #GPIO_MODER]			; This stores it back to memory


	; ODR Register
	;LDR r1, [r0, #GPIO_ODR]			; Stores the base address for ODR register in r1
	;ORR r1, r1,  #(0x1<<2)				; ODR is 1 bit wide so this turns on pin 2 of the ODR
	;STR r1, [r0, #GPIO_ODR]			; Stores back to memory

	; End Example

;Port Configurations
	; Mode Register Port A
	LDR r0, =GPIOA_BASE 				; Stores the port A base address in r0
	LDR r1, [r0, #GPIO_MODER]			; Stores the base address for mode register in r1
	LDR r2, =0xC0						; Buffering into r2
	BIC r1, r1,  r2						; MODER 2 bits wide so this clears pin 3 of the mode register (3*2)
	;ORR r1, r1,  r2						; this sets pin3 of the mode register to 01, which is output (3*2)
	STR r1, [r0, #GPIO_MODER]			; This stores it back to memory
	LDR r2, =0xC00						; Buffering into r2
	BIC r1, r1, r2						; MODER 2 bits wide so this clears pin 5 of the mode register (5*2)
	;ORR r1, r1,  r2						; this sets pin5 of the mode register to 01, which is output (5*2)
	STR r1, [r0, #GPIO_MODER]			; This stores it back to memory

	; Mode Register Port E
	LDR r0, =GPIOE_BASE 				; Stores the port E base address in r0
	LDR r1, [r0, #GPIO_MODER]			; Stores the base address for mode register in r1
	LDR r2, =0xFFF00000					; Buffering into r2
	BIC r1, r1,  r2						; MODER 2 bits wide so this clears pin 10-15 of the mode register (10*2)
	LDR r2, =0x55500000					; Buffering into r2
	ORR r1, r1,  r2						; this sets pin10-15 of the mode register to 01, which is output (10*2)
	STR r1, [r0, #GPIO_MODER]			; This stores it back to memory

	; Mode Register Port H
	LDR r0, =GPIOH_BASE 				; Stores the port H base address in r0
	LDR r1, [r0, #GPIO_MODER]			; Stores the base address for mode register in r1
	BIC r1, r1,  #(0x3)					; MODER 2 bits wide so this clears pin 0 of the mode register (0*2)
	ORR r1, r1,  #(0x1)					; this sets pin0 of the mode register to 01, which is output (0*2)
	STR r1, [r0, #GPIO_MODER]			; This stores it back to memory

	; OTyper port E
	LDR r0, =GPIOE_BASE					; Stores the port E base address in r0
	LDR r1, [r0, #GPIO_OTYPER]			; Stores the base address for otyper register in r1
	LDR r2, =0xFFF00000					; Buffering into r2
	BIC r1, r1, r2						; Clears pins 10-15, no setting necessary since it's push-pull
	STR r1, [r0, #GPIO_OTYPER]			; This stores it back to memory

	; OTyper port H
	LDR r0, =GPIOH_BASE					; Stores the port E base address in r0
	LDR r1, [r0, #GPIO_OTYPER]			; Stores the base address for otyper register in r1
	LDR r2, =0x00000001					; Buffering into r2
	BIC r1, r1, r2			; Clears pin 0, no setting necessary since it's push-pull
	STR r1, [r0, #GPIO_OTYPER]			; This stores it back to memory

	; PUPDR port A
	LDR r0, =GPIOA_BASE					; Stores the port A base address in r0
	LDR r1, [r0, #GPIO_PUPDR]			; Stores the base address for pupdr register in r1
	BIC r1, r1, #(0xCC0)				; Clears pin 3 and pin 5
	ORR r1, r1, #(0x880)				; Sets pin 3 and pin 5 to pull down
	STR r1, [r0, #GPIO_PUPDR]			; Stores back to memory

	; PUPDR port E
	LDR r0, =GPIOE_BASE					; Stores the port E base address in r0
	LDR r1, [r0, #GPIO_PUPDR]			; Stores the base address for pupdr register in r1
	LDR r2, =0xFFF00000					; Buffering into r2
	BIC r1, r1, r2						; Clears pins e10-e15
	STR r1, [r0, #GPIO_PUPDR]			; Stores back to memory

	; PUPDR port H
	LDR r0, =GPIOH_BASE					; Stores the port H base address in r0
	LDR r1, [r0, #GPIO_PUPDR]			; Stores the base address for pupdr register in r1
	BIC r1, r1, #(0x001)				; Clears pin 0
	STR r1, [r0, #GPIO_PUPDR]			; Stores back to memory
;Delay Setup	
	LDR r0, =STK_BASE
	LDR r1, [r0, #STK_CTRL]
	ORR r2, r1, #(0x7)
	STR r2, [r1]

	LDR r1, [r0, #STK_LOAD]
	LDR r2, =0x007A1200
	STR r2, [r1]


;Test Code
	;r0 Base
	;r1 ODR base
	;r2 Buffer Register
		
	;Turn on all segments test
	;LDR r0, =GPIOE_BASE					; Loads port E into r0
	;LDR r1, [r0, #GPIO_ODR]				; Loads E ODR into r4
	;LDR r2, =0xFD00						; Buffering Value
	;ORR r1, r1, r2						; Sets LED A-F on
	;STR r1, [r0, #GPIO_ODR]				; Stores back into memory
	;LDR r0, =GPIOH_BASE					; Loads port H into r5
	;LDR r1, [r0, #GPIO_ODR]				; Loads H ODR into r1
	;ORR r1, r1, #0x1					; Sets LED G on
	;STR r1, [r0, #GPIO_ODR]				; Stores back into memory
	LDR r4, =0xFFF
	LDR r7, =digit0
	BL assign
	BL delay
mainloopstart
	BL input
	CMP r6, #(0x00)
	BEQ next
	CMP r6, #(0x01)
	BEQ prev
always
	BL assign
	BL delay
	
	
	B mainloopstart
stop 	B 		stop     		; dead loop & program hangs here

next
	CMP r7, #digit0
	LDREQ r7, =digit1
	BEQ always
	CMP r7, #digit1
	LDREQ r7, =digit2
	BEQ always
	CMP r7, #digit2
	LDREQ r7, =digit3
	BEQ always
	CMP r7, #digit3
	LDREQ r7, =digit4
	BEQ always
	CMP r7, #digit4
	LDREQ r7, =digit5
	BEQ always
	CMP r7, #digit5
	LDREQ r7, =digit6
	BEQ always
	CMP r7, #digit6
	LDREQ r7, =digit7
	BEQ always
	CMP r7, #digit7
	LDREQ r7, =digit8
	BEQ always
	CMP r7, #digit8
	LDREQ r7, =digit9
	BEQ always
	CMP r7, #digit9
	LDREQ r7, =digit0
	BEQ always
	B always
prev
	CMP r7, #digit0
	LDREQ r7, =digit9
	BEQ always
	CMP r7, #digit9
	LDREQ r7, =digit8
	BEQ always
	CMP r7, #digit8
	LDREQ r7, =digit7
	BEQ always
	CMP r7, #digit7
	LDREQ r7, =digit6
	BEQ always
	CMP r7, #digit6
	LDREQ r7, =digit5
	BEQ always
	CMP r7, #digit5
	LDREQ r7, =digit4
	BEQ always
	CMP r7, #digit4
	LDREQ r7, =digit3
	BEQ always
	CMP r7, #digit3
	LDREQ r7, =digit2
	BEQ always
	CMP r7, #digit2
	LDREQ r7, =digit1
	BEQ always
	CMP r7, #digit1
	LDREQ r7, =digit0
	BEQ always
	B always

assign 
		;Assign function - Needs r7 to be set to bit mask for correct digit
		;assign in C:
			;GPIOE->ODR &= ~(0xFC00);
			;GPIOE->ODR |= (t)<<10;
			;GPIOH->ODR &= ~(0x0001);
			;if (t >> 6) GPIOH->ODR |= (0x1);
		;
	LDR r0, =GPIOE_BASE
	LDR r1, [r0, #GPIO_ODR]
	LDR r2, =0xFC00
	BIC r1, r1, r2
	ORR r1, r1, r7, LSL #10
	STR r1, [r0, #GPIO_ODR]
	LDR r0, =GPIOH_BASE
	LDR r1, [r0, #GPIO_ODR]
	LDR r2, =0x0001
	BIC r1, r1, r2
	ORR r1, r1, r7, LSR #6
	STR r1, [r0, #GPIO_ODR]
	BX LR

delay ; Delay function from lecture
	POP {r1}
	LDR r1, =100000   ;initial value for loop counter
again  NOP  ;execute two no-operation instructions
	NOP
	subs r1, #1
	bne again ; if not equal (Z?0)
	POP {r1}
	BX LR

		
	;Delay function I wrote, delays by the value stored in r4 in ms
delayStart
	CMP r5, r4
	BEQ out
	ADDNE r5, #0x1
	B delayStart
out	MOV r5, #0x0
	BX LR

input
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
		LDR r0, =GPIOA_BASE
		LDR r2, =0xFFFFFFFF
		EOR r2, r2, #0x28
start	LDR r1, [r0, #GPIO_IDR]
		BIC r1, r1, r2
		CMP r1, #0x08
		BEQ branch1
		CMP r1, #0x20
		BEQ branch2
		MOV r6, #0x02
		B start

branch1
		MOV r0, r6
		LDR r6, =0x0
		CMP r0, r6
		BEQ input
		BX LR
branch2
		MOV r0, r6
		LDR r6, =0x1
		CMP r0, r6
		BEQ input
		BX LR

;end stuff
	ENDP
	ALIGN			
	AREA    myData, DATA, READWRITE
	ALIGN
	END