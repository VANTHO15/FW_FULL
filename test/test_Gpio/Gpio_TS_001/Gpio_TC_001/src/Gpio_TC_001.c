#include <string.h>
#include "stm32f407xx.h"
#include "Gpio_TC_001.h"
#include "Gpio_TS_001.h"

#define HIGH 1
#define LOW 0

void delay(void)
{
	// this will introduce ~200ms delay when system clock is 16MHz
	for (uint32_t i = 0; i < 500000 / 2; i++)
		;
}

uint8_t count =0;
GPIO_Handle_t GpioLed;

void Gpio_TC_001(void)
{
	// this is led gpio configuration
	GpioLed.pGPIOx = GPIOD;
	GpioLed.GPIO_PinConfig.GPIO_PinNumber = GPIO_PIN_NO_12;
	GpioLed.GPIO_PinConfig.GPIO_PinMode = GPIO_MODE_OUT;
	GpioLed.GPIO_PinConfig.GPIO_PinSpeed = GPIO_SPEED_LOW;
	GpioLed.GPIO_PinConfig.GPIO_PinOPType = GPIO_OP_TYPE_PP;
	GpioLed.GPIO_PinConfig.GPIO_PinPuPdControl = GPIO_NO_PUPD;
	GPIO_Init(&GpioLed);

	GPIO_WriteToOutputPin(GPIOC, GPIO_PIN_NO_11, GPIO_PIN_RESET);

	delay();
	delay();
	GPIO_ToggleOutputPin(GPIOD, GPIO_PIN_NO_12);
	count ++;
	delay();
	delay();
	GPIO_ToggleOutputPin(GPIOD, GPIO_PIN_NO_12);
	count ++;
	delay();
	delay();
	GPIO_ToggleOutputPin(GPIOD, GPIO_PIN_NO_12);
	count ++;
	delay();
	delay();
	GPIO_ToggleOutputPin(GPIOD, GPIO_PIN_NO_12);
	count ++;
	delay();
	delay();
	GPIO_ToggleOutputPin(GPIOD, GPIO_PIN_NO_12);
	count ++;
	delay();
	delay();
	GPIO_ToggleOutputPin(GPIOD, GPIO_PIN_NO_12);
	count ++;
	delay();
	delay();
	GPIO_ToggleOutputPin(GPIOD, GPIO_PIN_NO_12);
	count ++;
	delay();
	delay();
	GPIO_ToggleOutputPin(GPIOD, GPIO_PIN_NO_12);
	count ++;
	delay();
	delay();
	
	RESULT_Assert(count == 8);
}
