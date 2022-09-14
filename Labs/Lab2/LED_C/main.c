#include "stm32l476xx.h"
void initAPins();
void initEPins();
void delayLED(uint32_t);
void assign(uint32_t);
void shiftLeft(uint32_t *);
void shiftRight(uint32_t *);
void leadLight();
#define STRIP_DELAY_CNST 100

uint32_t msTicks=0; //Global variable to increment each clock cycle using systick

void SysTick_Handler(void) {		//increments msTicks each clock cycle, for use in delay function
	msTicks++;
}
void initAPins(){			//Sets up port A pins 0-3 as output, push-pull, no-pull up pulldown
  //GPIO A things
  RCC->AHB2ENR |= RCC_AHB2ENR_GPIOAEN;     //Enable clock for port A
  int pinOffset = 0;
	//in hindsight could just used a mask that enabled multiple pins at a time on the register, but this also works since they were consecutive pins.
  for (pinOffset = 0; pinOffset <= 3; pinOffset++){
    //each pin is 2 bits wide
    GPIOA->MODER &= ~(0x03<<(2*pinOffset)); // clears pin 10 (format is 2*desired pin to clear)
    GPIOA->MODER |= 0x01<<(2*pinOffset); //sets pin 10 as output

    //each pin is 1 bit wide
    GPIOA->OTYPER &= ~(0x01<<(1*pinOffset)); // Cleared pin, because push-pull is 0 we don't need to set any bits
    //each pin is 2 bits wide
    GPIOA->PUPDR &= ~(0x03<<(2*pinOffset));
    //the and function sets the bits to 00 and that is the desired outcome so we dont need an or function
  }
}
void initEPins(){			//Sets up port E pins 10-15 as output, push-pull, no-pull up pulldown
  //GPIO E things
  RCC->AHB2ENR |= RCC_AHB2ENR_GPIOEEN;     //Enable clock for port E
  int pinOffset = 10;
  for (pinOffset = 10; pinOffset <= 15; pinOffset++){
    //each pin is 2 bits wide
    GPIOE->MODER &= ~(0x03<<(2*pinOffset)); // clears pin 10 (format is 2*desired pin to clear)
    GPIOE->MODER |= 0x01<<(2*pinOffset); //sets pin 10 as output

    //each pin is 1 bit wide
    GPIOE->OTYPER &= ~(0x01<<(1*pinOffset)); // Cleared pin, because push-pull is 0 we don't need to set any bits
    //each pin is 2 bits wide
    GPIOE->PUPDR &= ~(0x03<<(2*pinOffset));
    //the and function sets the bits to 00 and that is the desired outcome so we dont need an or function
  }
}
void delayLED(uint32_t timeValue){	//delay function using systick that waits timeValue miliseconds before ending the function
	uint32_t curTicks;
	curTicks = msTicks;
	while ((msTicks - curTicks) < timeValue);
}
void shiftRight(uint32_t *mask){	//shifts the mask so that the next LED in the sequence will be the one to light up
  *mask = (*mask) >> 1;
}
void shiftLeft(uint32_t *mask){	//same as above but other wise
  *mask = (*mask) << 1;
}
void assign(uint32_t t) {	//used to handle the pins being split across multiple ports
  GPIOE->ODR &= ~(0xFC00);
  GPIOE->ODR |= (t>>4)<<10;
  GPIOA->ODR &= ~(0x000F);
  GPIOA->ODR |= (t & 0x00F);
}

void leadLight(){		//original function used to move the primary, full brightness light across the strip
  uint32_t t;
  t = 0x1<<9;
  int i = 0;
  for(i = 0; i < 10; i++){
    assign(t);
    delayLED(STRIP_DELAY_CNST);
    shiftRight(&t);
  }
  t = 0x1;
  for(i = 0; i < 10; i++){
    assign(t);
    delayLED(STRIP_DELAY_CNST);
    shiftLeft(&t);
  }
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

	initEPins();
  initAPins();
	SysTick_Config(16000000/1000); //configures the system clock based on it being the 16MHz HSI clock to do a systick every milisecond
  while(1){
    leadLight();
  }


	}
