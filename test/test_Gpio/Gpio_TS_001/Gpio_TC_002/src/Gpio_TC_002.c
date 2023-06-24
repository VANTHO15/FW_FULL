#include <string.h>
#include "stm32f407xx.h"
#include "Gpio_TC_002.h"
#include "Gpio_TS_001.h"

void Gpio_TC_002(void)
{
	RESULT_Assert(8==9);
	RESULT_Assert(8==8);
	RESULT_Assert(8==9);
	RESULT_Assert(8==8);
}
