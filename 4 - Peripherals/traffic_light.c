#include <traffic_light.h>
#include "stm32f4xx.h"

// ###########################################
// #########        VARIABLES        #########
// ###########################################

/*
 * TODO:
 * Declare all variables you need for your traffic light state machine.
 * Remember that you need to have the following light sequence:
 * 1. red
 * 2. red + yellow
 * 3. green
 * 4. yellow
 * -> repeat
 */

// 1: red, 2: red & yellow, 3: green, 4: yellow, 0: error handling
unsigned next_state;
enum {RED, REDYELLOW, GREEN, YELLOW} state;

// ###########################################
// #########        FUNCTIONS        #########
// ###########################################

/*
 * TODO:
 * Initialize all variables you need for your traffic light state machine.
 * The light should be set to red at the start.
 * Do not physically turn on LEDs in this function.
 */
void TrafficLight_initializeStateMachine()
{
	state = 1;
	next_state = 0;
}

/*
 * TODO:
 * Initialize the red, yellow(=orange) and green LEDs of the board.
 */
void TrafficLight_initializeLEDs()
{
	RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOD, ENABLE);

	GPIO_InitTypeDef ledInitStruct_red;
	GPIO_InitTypeDef ledInitStruct_yellow;
	GPIO_InitTypeDef ledInitStruct_green;

	GPIO_StructInit(&ledInitStruct_red);
	GPIO_StructInit(&ledInitStruct_yellow);
	GPIO_StructInit(&ledInitStruct_green);

	ledInitStruct_red.GPIO_Pin = GPIO_Pin_14;
	ledInitStruct_yellow.GPIO_Pin = GPIO_Pin_13;
	ledInitStruct_green.GPIO_Pin = GPIO_Pin_12;

	ledInitStruct_red.GPIO_Mode = GPIO_Mode_OUT;
	ledInitStruct_yellow.GPIO_Mode = GPIO_Mode_OUT;
	ledInitStruct_green.GPIO_Mode = GPIO_Mode_OUT;

	GPIO_Init(GPIOD, &ledInitStruct_red);
	GPIO_Init(GPIOD, &ledInitStruct_yellow);
	GPIO_Init(GPIOD, &ledInitStruct_green);
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
void TrafficLight_initializeTimer()
{
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_TIM9, ENABLE);

	TIM_TimeBaseInitTypeDef timerInitStruct;
	TIM_TimeBaseStructInit(&timerInitStruct);

	/* 168,000,000 / 40,000 = 4200 /s => 6300 /1.5s */
	timerInitStruct.TIM_Prescaler = 40000;
	timerInitStruct.TIM_Period = 6300;

	TIM_TimeBaseInit(TIM9, &timerInitStruct);

	NVIC_EnableIRQ(TIM1_BRK_TIM9_IRQn);
	TIM_ITConfig(TIM9, TIM_IT_Update, ENABLE);

	TIM_ClearFlag(TIM9, TIM_FLAG_Update);

	TIM_Cmd(TIM9, ENABLE);
}


/*
 * TODO:
 * Set your state machine to the next state.
 * Call this function in the timer interrupt handler.
 */
void TrafficLight_updateStateMachine()
{
	switch (state) {
		case RED:
			state = REDYELLOW;
			break;
		case REDYELLOW:
			state = GREEN;
			break;
		case YELLOW:
			state = RED;
			break;
		case GREEN:
			state = YELLOW;
			break;
		default:
			state = RED;
			break;
	}
}

/*
 * TODO:
 * Switch all LEDs off except for the ones which should be currently on.
 * Call this function in the timer interrupt handler.
 */
void TrafficLight_updateTrafficLight()
{
	switch (state) {
		case RED:
			GPIO_SetBits(GPIOD, GPIO_Pin_13);
			break;
		case REDYELLOW:
			GPIO_ResetBits(GPIOD, GPIO_Pin_14);
			GPIO_ResetBits(GPIOD, GPIO_Pin_13);
			GPIO_SetBits(GPIOD, GPIO_Pin_12);
			break;
		case YELLOW:
			GPIO_SetBits(GPIOD, GPIO_Pin_14);
			GPIO_ResetBits(GPIOD, GPIO_Pin_13);
			break;
		case GREEN:
			GPIO_SetBits(GPIOD, GPIO_Pin_13);
			GPIO_ResetBits(GPIOD, GPIO_Pin_12);
			break;
		default:
			GPIO_SetBits(GPIOD, GPIO_Pin_14);
			break;
	}
}

// ###########################################
// #########   INTERRUPT HANDLERS    #########
// ###########################################

/*
 * TODO:
 * Implement the required timer interrupt handler here.
 * Check whether the interrupt was caused by the update event and handle it correctly.
 * In that case the interrupt handler should:
 * 	- update the state machine
 * 	- activate the current LEDs
 * 	- disable the other LEDs
 */
void TIM1_BRK_TIM9_IRQHandler()
{
	if (TIM_GetFlagStatus(TIM9, TIM_FLAG_Update) == SET) {
		TrafficLight_updateStateMachine();
		TrafficLight_updateTrafficLight();
		TIM_ClearFlag(TIM9, TIM_FLAG_Update);
	}
}
