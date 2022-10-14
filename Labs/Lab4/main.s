;******************** (C) Yifeng ZHU *******************************************
; @file    main.s
; @author  Yifeng Zhu
; @date    May-17-2015
; @note
;           This code is for the book "Embedded Systems with ARM Cortex-M 
;           Microcontrollers in Assembly Language and C, Yifeng Zhu, 
;           ISBN-13: 978-0982692639, ISBN-10: 0982692633
; @attension
;           This code is provided for education purpose. The author shall not be 
;           held liable for any direct, indirect or consequential damages, for any 
;           reason whatever. More information can be found from book website: 
;           http:;www.eece.maine.edu/~zhu/book
;*******************************************************************************

	INCLUDE core_cm4_constants.s		; Load Constant Definitions
	INCLUDE stm32l476xx_constants.s      

	AREA    main, CODE, READONLY
	EXPORT	__main				; make __main visible to linker
	ENTRY			


			
__main	PROC
	




;Register usage:
	; r0 - Stores base address for Port or Clock
	; r1 - Stores base address for specific register or clock port
	; r2 - Used as a buffer for instructions
	;
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

;Example Code for Clock from template
    ;Enable the clock to GPIO Port B	
	;LDR r0, =RCC_BASE   				; Stores base clock address in r0
	;LDR r1, [r0, #RCC_AHB2ENR]			; Stores the clock enable register in r1;
	;ORR r1, r1, #RCC_AHB2ENR_GPIOBEN	; Enables Clock
	;STR r1, [r0, #RCC_AHB2ENR]			; Stores data back to memory


;Clock Setup
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
	LDR r2, =0xD0						; Buffering into r2
	BIC r1, r1,  r2						; MODER 2 bits wide so this clears pin 3 of the mode register (3*2)
	ORR r1, r1,  r2						; this sets pin3 of the mode register to 01, which is output (3*2)
	LDR r2, =0xD00						; Buffering into r2
	BIC r1, r1, r2						; MODER 2 bits wide so this clears pin 5 of the mode register (5*2)
	ORR r1, r1,  r2						; this sets pin5 of the mode register to 01, which is output (5*2)
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
	BIC r1, r1, #(0xDD0)				; Clears pin 3 and pin 5
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


;Test Code
	;r0 A Base
	;r1 A ODR base
	;r2 Buffer Register
	;r3	E Base
	;r4 E ODR base
	;r5 H Base
	;r6 H ODR base
		
	;Turn on all segments test
	LDR r0, =GPIOA_BASE					; Loads port A into r0
	LDR r3, =GPIOE_BASE					; Loads port E into r3
	LDR r5, =GPIOH_BASE					; Loads port H into r5
	LDR r4, [r3, #GPIO_ODR]				; Loads E ODR into r4
	LDR r2, =0xFD00						; Buffering Value
	ORR r4, r4, r2						; Sets LED A-F on
	STR r4, [r3, #GPIO_ODR]				; Stores back into memory
	LDR r6, [r5, #GPIO_ODR]				; Loads H ODR into r1
	ORR r6, r6, #0x1					; Sets LED G on
	STR r6, [r5, #GPIO_ODR]				; Stores back into memory

	



;end stuff

;Use BL to jump to assign function, BX LR to get back to main
	LDR r7, =digit0
	BL assign


stop 	B 		stop     		; dead loop & program hangs here

	ENDP
					
	ALIGN			

	AREA    myData, DATA, READWRITE
	ALIGN
;array	DCD   1, 2, 3, 4
	END

assign:
	;Assign function - Needs r7 to be set to bit mask for correct digit
	;assign in C:
		;GPIOE->ODR &= ~(0xFC00);
		;GPIOE->ODR |= (t)<<10;
		;GPIOH->ODR &= ~(0x0001);
		;if (t >> 6) GPIOH->ODR |= (0x1);
	;
	LDR r0, =GPIOE_BASE
	LDR r1, [r0, GPIO_ODR]
	LDR r2, =0xFC00
	BIC r1, r1, r2
	ORR r1, r1, r7, LSL 10
	LDR r0, =GPIOH_BASE
	LDR r1, [r0, GPIO_ODR]
	LDR r2, =0x0001
	BIC r1, r1, r2
	ORR r1, r1, r7, LSR 6
	BX LR

delay:
	;Delay function, delays by the value stored in r7
		