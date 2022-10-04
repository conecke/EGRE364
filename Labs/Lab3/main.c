#include "stm32l476xx.h"
void initAPins();
void initEPins();
void initHPins();
void delay(uint32_t);
void assign(uint32_t);
int inputVal();

#define digit0 0x3F
#define digit1 0x06
#define digit2 0x5B 
#define digit3 0x4F 
#define digit4 0x66
#define digit5 0x6D 
#define digit6 0x7D 
#define digit7 0x07 
#define digit8 0x7F
#define digit9 0x6F 

uint32_t msTicks=0; //Global variable to increment each clock cycle using systick

void SysTick_Handler(void) {	//increments msTicks each clock cycle, for use in delay function
	msTicks++;
}
void initAPins(){			//Sets up port A pins 3 and 5 as output, push-pull, no-pull up pulldown
	//GPIO A things
	RCC->AHB2ENR |= RCC_AHB2ENR_GPIOAEN;     //Enable clock for port A
	int pinOffset = 0;
	

	//each pin is 2 bits wide
	GPIOA->MODER &= ~(0x03<<(2*3)); //Clears GIPIOA Mode for Pin 3
	GPIOA->MODER &= ~(0x03<<(2*5)); //Clears GIPIOA Mode Pin 5
	
	//GPIOA->OTYPER &= ~(0x01<< (1*3)); //Clears Pin3 type, making it push pull
	//GPIOA->OTYPER &= ~(0x01<< (1*5)); //Clears Pin5 type, making it push pull
	
	GPIOA->PUPDR  &= ~(0x03<<(2*3)); //Clears PUPDR register for 3
	GPIOA->PUPDR  &= ~(0x03<<(2*5)); //Clears PUPDR register for 5
	
	GPIOA->PUPDR |= (0x02 << (2*3)); //Sets pin 3 to pull down
	GPIOA->PUPDR |= (0x02 << (2*5)); //Sets pin 5 to pull down
	


 
}
void initHPins(){			//Sets up port A pins 0-3 as output, push-pull, no-pull up pulldown
  //GPIO A things
  RCC->AHB2ENR |= RCC_AHB2ENR_GPIOHEN;     //Enable clock for port A
  int pinOffset = 0;
	//in hindsight could just used a mask that enabled multiple pins at a time on the register, but this also works since they were consecutive pins.
    //each pin is 2 bits wide
    GPIOH->MODER &= ~(0x03<<(2*pinOffset)); // clears pin 10 (format is 2*desired pin to clear)
    GPIOH->MODER |= 0x01<<(2*pinOffset); //sets pin 10 as output

    //each pin is 1 bit wide
    GPIOH->OTYPER &= ~(0x01<<(1*pinOffset)); // Cleared pin, because push-pull is 0 we don't need to set any bits
    //each pin is 2 bits wide
    GPIOH->PUPDR &= ~(0x03<<(2*pinOffset));
	//GPIOH->PUPDR |= 0x10 << (2*pinOffset);
    //the and function sets the bits to 00 and that is the desired outcome so we dont need an or function
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
	//GPIOE->PUPDR |= (0x10<<(2*pinOffset));
    //the and function sets the bits to 00 and that is the desired outcome so we dont need an or function
  }
}
void delay(uint32_t timeValue){	//delay function using systick that waits timeValue miliseconds before ending the function
	uint32_t curTicks;
	curTicks = msTicks;
	while ((msTicks - curTicks) < timeValue);
}

void assign(uint32_t t) {	//used to handle the pins being split across multiple ports
	
  GPIOE->ODR &= ~(0xFC00);
  GPIOE->ODR |= (t)<<10;
	GPIOH->ODR &= ~(0x0001);
  if (((t<<25)>>25) >> 6) GPIOH->ODR |= (0x1);

}

int inputVal(){
	
	while (1){
		uint32_t data = GPIOA->IDR;
		if ((data & (0x1 << 3))){
			return 1;
		}
		else if ((data & (0x01 << 5))){
			return -1;
		}

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


  initAPins();
  initEPins();
  initHPins();
  SysTick_Config(16000000/1000); //configures the system clock based on it being the 16MHz HSI clock to do a systick every milisecond
		
	uint32_t digits[10] = {digit0, digit1, digit2, digit3, digit4, digit5, digit6, digit7, digit8, digit9};
		
	int i = 0, input = 0;
	int boolean = 0;
		
	while(1){
			
			if (!boolean) {
				assign(digits[0]);
				boolean = 1;
			}
			input = inputVal();
			if(input == -1 && i == 0){
				i = 9;

			}
			else if(input == -1){
				i--;

			}

			if (input == 1 && i == 9){
				i = 0;

			}
			else if(input == 1){
				i++;
				
			}
			assign(digits[i]);
			while (GPIOA->IDR & 0x01<<3 || GPIOA->IDR & 0x01 <<5);
			delay(300);
			/*
			for(i = 0; i < 10; i++){
				assign(digits[i]);
				delay(1000);
			}
			*/
	}
	
	
    
	
		
 

}


	
