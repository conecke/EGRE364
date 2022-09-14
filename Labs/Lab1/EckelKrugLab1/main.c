#include "stm32l476xx.h"

uint32_t msTicks=0;
void SysTick_Handler(void) {
msTicks++;
}
/*----------------------------------------------------------------------------
delays number of tick Systicks (happens every 1 ms)
*----------------------------------------------------------------------------*/
void Delay (uint32_t dlyTicks) {
uint32_t curTicks;
curTicks = msTicks;
while ((msTicks - curTicks) < dlyTicks);
}

int main(void){
	
	// Enable High Speed Internal Clock (HSI = 16 MHz)
  RCC->CR |= ((uint32_t)RCC_CR_HSION);

  // wait until HSI is ready
  while ( (RCC->CR & (uint32_t) RCC_CR_HSIRDY) == 0 ) {;}

  // Select HSI as system clock source
  RCC->CFGR &= (uint32_t)((uint32_t)~(RCC_CFGR_SW));
  RCC->CFGR |= (uint32_t)RCC_CFGR_SW_HSI;  //01: HSI16 oscillator used as system clock

  // Wait till HSI is used as system clock source
  while ((RCC->CFGR & (uint32_t)RCC_CFGR_SWS) == 0 ) {;}

  // Enable the clock to GPIO Port B
  RCC->AHB2ENR |= RCC_AHB2ENR_GPIOBEN;

		/*

		old given code
		MODE: 00: Input mode, 01: General purpose output mode
	  10: Alternate function mode, 11: Analog mode (reset state)
	  GPIOB->MODER &= ~(0x03<<(2*2)) ;   // Clear bit 13 and bit 12
	  GPIOB->MODER |= (1<<4);


		0011 << 4 = 0000, 0x03 shifted by 4
		00000000000000000000000000000000
		00000000000000000000000000000001
		<<4 	00000000000000000000000000010000
		                                 ^ pin 2 is now set to mode 01 which is output
		//What is this called?
		//0x0000002u -> 0000/0000/0000/0000/0000/0000/0010/u // Port B Enable
		//0x0000012u -> 0000/0000/0000/0000/0000/0001/0010/u // Port B and E Enable

		//1UL = 00000000000000000000000000000001
		//~ 1Ul (not 1Ul) = 11111111111111111111111111111110 (when anded with port B pins this will keep everything we dont care about the same )

		*/


		GPIOB->MODER &= ~(0x03<<(2*2)); // Clear bits 4 and 5 for Pin 2
		GPIOB->MODER |= 0x01<<4; // Set bit 4, set Pin 2 as output


		GPIOB->OTYPER &= ~(0x01<<(2*1)); //sets to zero
			// GPIOB->OTYPER |= 0x01<<(2*1);    //sets to 1 which would make PB2 Open Drain, which is not what we want

		GPIOB->PUPDR &= ~(0x03<<(2*2));
			//the and function sets the bits to 00 and that is the desired outcome so we dont need an or function



		GPIOB->ODR |= GPIO_ODR_ODR_2;

		//GPIO E things
		RCC->AHB2ENR |= RCC_AHB2ENR_GPIOEEN;     //Enable clock for port E
		//each pin is 2 bits wide
		GPIOE->MODER &= ~(0x03<<(2*8)); // clears pin 8 (format is 2*desired pin to clear)
		GPIOE->MODER |= 0x01<<(2*8);
		//each pin is 1 bit wide
		GPIOE->OTYPER &= ~(0x01<<(1*8)); // Cleared pin, because push-pull is 0 we don't need to set any bits

		GPIOE->PUPDR &= ~(0x03<<(2*8));
		//the and function sets the bits to 00 and that is the desired outcome so we dont need an or function
		
		SysTick_Config(16000000/1000);
		
		while(1){

			  // Dead loop & program hangs here
				volatile int i = 0;
				//turn on red light and green light
				GPIOB->ODR |= 0x01<<(1*2);
				GPIOE->ODR |= 0x01<<(1*8);

				//Delay
        Delay(500);

				//Turn off red light and green light
				 GPIOB->ODR &= ~(0x01<<(1*2));
				 GPIOE->ODR &= ~(0x01UL<<(1*8));
			  Delay(500);

		}

	}
