#include <evil_eye.h>
#include "stm32f4xx.h"

// ###########################################
// #########        FUNCTIONS        #########
// ###########################################

/*
 * TODO:
 * Initialize the blue LED of the board.
 */
void EvilEye_initializeLED()
{
	RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOD, ENABLE);

	GPIO_InitTypeDef ledInitStruct_blue;

	GPIO_StructInit(&ledInitStruct_blue);

	ledInitStruct_blue.GPIO_Pin = GPIO_Pin_15;

	ledInitStruct_blue.GPIO_Mode = GPIO_Mode_OUT;

	GPIO_Init(GPIOD, &ledInitStruct_blue);
}

/*
 * TODO:
 * Initialize a timer of your choice to generate an update event at the correct interval:
 * - configure the timer
 * - enable the interrupt for your timer
 * - manually clear the update event flag
 * - enable the interrupt in the NVIC
 * - enable the timer
 * Hint: The �P runs at maximum speed of 168MHz.
 */
void EvilEye_initializeTimer()
{
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_TIM10, ENABLE);

	TIM_TimeBaseInitTypeDef timerInitStruct;
	TIM_TimeBaseStructInit(&timerInitStruct);

	/* 168,000,000 / 40,000 = 4200 /s => 2520 / 0.6s */
	timerInitStruct.TIM_Prescaler = 40000;
	timerInitStruct.TIM_Period = 2520;

	TIM_TimeBaseInit(TIM10, &timerInitStruct);

	NVIC_EnableIRQ(TIM1_UP_TIM10_IRQn);
	TIM_ITConfig(TIM10, TIM_IT_Update, ENABLE);

	TIM_ClearFlag(TIM10, TIM_FLAG_Update);

	TIM_Cmd(TIM10, ENABLE);
}


// ###########################################
// #########   INTERRUPT HANDLERS    #########
// ###########################################

/*
 * TODO:
 * Implement the required timer interrupt handler here.
 * Check whether the interrupt was caused by the update event and handle it correctly.
 * In that case the interrupt handler should:
 * 	- toggle the blue LED
 */
void TIM1_UP_TIM10_IRQHandler()
{
	if (TIM_GetFlagStatus(TIM10, TIM_FLAG_Update) == SET) {
		GPIO_ToggleBits(GPIOD, GPIO_Pin_15);
		TIM_ClearFlag(TIM10, TIM_FLAG_Update);
	}
}
