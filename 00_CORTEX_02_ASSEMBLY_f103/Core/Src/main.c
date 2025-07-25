/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : main.c
  * @brief          : Main program body
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2022 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
  */
/* USER CODE END Header */
/* Includes ------------------------------------------------------------------*/
#include "main.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */
#include <stdio.h>
#include <string.h>

/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */

/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */
#define __bswap_32(x) \
     ((((x) & 0xff000000) >> 24) | (((x) & 0x00ff0000) >>  8) |                      \
      (((x) & 0x0000ff00) <<  8) | (((x) & 0x000000ff) << 24))
/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/
 UART_HandleTypeDef huart2;

/* USER CODE BEGIN PV */

/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
static void MX_GPIO_Init(void);
static void MX_USART2_UART_Init(void);
/* USER CODE BEGIN PFP */
int FIRST_ASM_FUNC(int,int,int,int,int,int);
int ADD8(char a, char b);
int ADD32(int a, int b);
int max(int num1, int num2);
int max2(int num1, int num2);
int clear_unused(int v, int bitnum);
int clears_unused(int v, int bitnum);
int sum(int start, int end);
void MEMCPY_SINGLE(unsigned long dst, unsigned long src, int size);
void MEMCPY_BLOCK(unsigned long dst, unsigned long src, int size);
int __bswap_32_asm(int);
void mem32set (void *dest, int val, size_t len);
void dump_m(uint32_t* pulMemAddr);
int whereIsBit(int);
/* USER CODE END PFP */

/* Private user code ---------------------------------------------------------*/
/* USER CODE BEGIN 0 */
int __io_putchar(int ch)
{
 if ( ch == '\n' )
	 HAL_UART_Transmit(&huart2, (uint8_t*)&"\r", 1, HAL_MAX_DELAY);
 HAL_UART_Transmit(&huart2, (uint8_t*)&ch, 1, HAL_MAX_DELAY);
 return ch;
}

int __io_getchar(void)
{
	uint8_t ch;

	while( HAL_OK != HAL_UART_Receive(&huart2, &ch, 1, HAL_MAX_DELAY) )
	{
		;
	}
	return ch;
}

/* USER CODE END 0 */

/**
  * @brief  The application entry point.
  * @retval int
  */
int main(void)
{
  /* USER CODE BEGIN 1 */

  /* USER CODE END 1 */

  /* MCU Configuration--------------------------------------------------------*/

  /* Reset of all peripherals, Initializes the Flash interface and the Systick. */
  HAL_Init();

  /* USER CODE BEGIN Init */

  /* USER CODE END Init */

  /* Configure the system clock */
  SystemClock_Config();

  /* USER CODE BEGIN SysInit */

  /* USER CODE END SysInit */

  /* Initialize all configured peripherals */
  MX_GPIO_Init();
  MX_USART2_UART_Init();
  /* USER CODE BEGIN 2 */
  printf("\n\n\nHELLO, STM32\n");
  SCB->SHCSR = SCB->SHCSR | (7<<16); // If you do not do this, it will be treated as a hard fault.

	/*
	 * ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	 *   FROM HERE WE WILL TEST ARM INSTRUCTION
	 */
  // AAPCS(Procedure Call Standard for ARM Architecture)
	// r0,r1,r2,r3 : scratch(temporary) register
  // r0 : return value
#if 1
	{
  	/* ex1. call assembly function */
  	printf("result=%d\n", FIRST_ASM_FUNC(7,8,9,10,11,12));
  	printf("do you see this line? \n");
	}
#endif

#if 0
	{
	   /* actual initialization */
	   char a8 = 10;
	   char b8 = 20;
	   char sum8;

	   int a32 = 10;
	   int b32 = 20;
	   int sum32;

	   /* function returning add two numbers */
	   printf("ex2. add two numbers\n");

	   sum8= ADD8(a8, b8); // sum8 = a8 + b8
	   printf("value of char c : %d (must 30) \n", sum8);

	   sum32= ADD32(a32, b32); // sum32 = a32 + b32
	   printf("value of int c : %d (must 30) \n", sum32);
	   __BKPT(0);
	}
#endif

#if 0
	{
		/* actual initialization */
		volatile int result;
		int a=34;
		int b=100;

		/* function returning the max between two numbers */
		printf("ex3. get max value\n");

		result = max(a, b);
		printf("Max value is : %d (must 100)\n", result);
		result = max2(a, b);
		printf("Max2 value is : %d (must 100)\n", result);
		__BKPT(0);
	}
#endif

#if 0
	{
		/* actual initialization */
		volatile unsigned result1;
		volatile unsigned result2;

		unsigned int a1=0xffffffff;
		unsigned int a2;

		int bitnum1 = 0;
		int pattern = 0xc0; // 7번, 6번 비트 지움 binary=1100 0000

		/* function returning a & ~(1<<bitnum) */
		printf("ex4. bit clear(mask off)\n");

		result1 = clear_unused(a1, bitnum1);
		result2 = clears_unused(a2, pattern);
		printf("masked value is : 0x%08x (must 0x12340078)\n", result1);
		printf("masked values is : 0x%08x \n", result2);
		__BKPT(0);
	}
#endif

#if 0
	/* Sum from 1 to 100 */
{
	int start=1, end=100;
	int result;

	printf("ex5. Sum from 1 to 100\n");

	result = sum(start, end);
	printf("sum is %d\n", result);
	__BKPT(0);
}
#endif

#if 0
/* Memory Copy */
{
	unsigned int src=0x20004000;
	unsigned int dst=0x20004800;
	int size = 16; /* word size */
	unsigned int v;

#if 0
	/* memory copy by LDR/STR */
	v = 0x12345678;
	printf("ex6. MEMCPY_SINGLE\n");

	printf("\nmemory address @0x%08x filled with [0x%08x]\n", src, v);
	mem32set((char*)src, v, size+4); // write 80bytes
	mem32set((char*)dst, 0x00000000, size+4); // write 80bytes
	dump_m((uint32_t*)src); // print the buffer contents to the screen

	printf("\nsingle copy from @0x%08x to @0x%08x\n",src, dst);
	//MEMCPY_SINGLE(dst, src, size);
	memcpy((void*)dst, (void*)src, size*4); // write 64bytes
	dump_m((uint32_t*)dst); // print the buffer contents to the screen
	__BKPT(0);
#endif

#if 0
	/* memory copy test with multiple LDM/STM */
	v = 0x12345678;
	printf("ex7. MEMCPY_BLOCK\n");

	printf("\nmemory address @0x%08x filled with [0x%08x]\n", src, v);
	mem32set((char*)src, v, size+4);
	mem32set((char*)dst, 0x00000000, size+4);
	dump_m((uint32_t*)src); // print the buffer contents to the screen
	printf("\nblock copy from @0x%08x to @0x%08x\n",src, dst);
	MEMCPY_BLOCK_PRAC(dst, src, size);
	dump_m((uint32_t*)dst); // print the buffer contents to the screen
	__BKPT(0);
#endif
}
#endif

#if 0
	/* IMPLEMENT the function for Swap bytes in 32 bit value */
{
	unsigned int a;
	volatile unsigned int result;

	a = 0x00000001;
	printf("ex8. Swap bytes in 32 bit value\n");
	printf("before swap (0x%08x) \n",a);
	result = __bswap_32_asm(a);
	printf("after swap (0x%08x) (must 0x%08x) \n", result, (unsigned int)__bswap_32(a));
	__BKPT(0);
}
#endif

#if 0
{
	int c=0x00000003;
	int result;

	result=whereIsBit(c); // by instruction CLZ
	printf("The position of the searched bit is %d\n", result);
}
#endif

#if 0
void xPSR_TEST(void);
	xPSR_TEST();
#endif

  /* USER CODE END 2 */

  /* Infinite loop */
  /* USER CODE BEGIN WHILE */
  while (1)
  {
    /* USER CODE END WHILE */

    /* USER CODE BEGIN 3 */
  }
  /* USER CODE END 3 */
}

/**
  * @brief System Clock Configuration
  * @retval None
  */
void SystemClock_Config(void)
{
  RCC_OscInitTypeDef RCC_OscInitStruct = {0};
  RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};

  /** Initializes the RCC Oscillators according to the specified parameters
  * in the RCC_OscInitTypeDef structure.
  */
  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSI;
  RCC_OscInitStruct.HSIState = RCC_HSI_ON;
  RCC_OscInitStruct.HSICalibrationValue = RCC_HSICALIBRATION_DEFAULT;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
  RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSI_DIV2;
  RCC_OscInitStruct.PLL.PLLMUL = RCC_PLL_MUL16;
  if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
  {
    Error_Handler();
  }

  /** Initializes the CPU, AHB and APB buses clocks
  */
  RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK|RCC_CLOCKTYPE_SYSCLK
                              |RCC_CLOCKTYPE_PCLK1|RCC_CLOCKTYPE_PCLK2;
  RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
  RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV2;
  RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;

  if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_2) != HAL_OK)
  {
    Error_Handler();
  }
}

/**
  * @brief USART2 Initialization Function
  * @param None
  * @retval None
  */
static void MX_USART2_UART_Init(void)
{

  /* USER CODE BEGIN USART2_Init 0 */

  /* USER CODE END USART2_Init 0 */

  /* USER CODE BEGIN USART2_Init 1 */

  /* USER CODE END USART2_Init 1 */
  huart2.Instance = USART2;
  huart2.Init.BaudRate = 115200;
  huart2.Init.WordLength = UART_WORDLENGTH_8B;
  huart2.Init.StopBits = UART_STOPBITS_1;
  huart2.Init.Parity = UART_PARITY_NONE;
  huart2.Init.Mode = UART_MODE_TX_RX;
  huart2.Init.HwFlowCtl = UART_HWCONTROL_NONE;
  huart2.Init.OverSampling = UART_OVERSAMPLING_16;
  if (HAL_UART_Init(&huart2) != HAL_OK)
  {
    Error_Handler();
  }
  /* USER CODE BEGIN USART2_Init 2 */

  /* USER CODE END USART2_Init 2 */

}

/**
  * @brief GPIO Initialization Function
  * @param None
  * @retval None
  */
static void MX_GPIO_Init(void)
{
  GPIO_InitTypeDef GPIO_InitStruct = {0};

  /* GPIO Ports Clock Enable */
  __HAL_RCC_GPIOC_CLK_ENABLE();
  __HAL_RCC_GPIOD_CLK_ENABLE();
  __HAL_RCC_GPIOA_CLK_ENABLE();
  __HAL_RCC_GPIOB_CLK_ENABLE();

  /*Configure GPIO pin Output Level */
  HAL_GPIO_WritePin(LD2_GPIO_Port, LD2_Pin, GPIO_PIN_RESET);

  /*Configure GPIO pin : B1_Pin */
  GPIO_InitStruct.Pin = B1_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_IT_RISING;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  HAL_GPIO_Init(B1_GPIO_Port, &GPIO_InitStruct);

  /*Configure GPIO pin : LD2_Pin */
  GPIO_InitStruct.Pin = LD2_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(LD2_GPIO_Port, &GPIO_InitStruct);

  /* EXTI interrupt init*/
  HAL_NVIC_SetPriority(EXTI15_10_IRQn, 0, 0);
  HAL_NVIC_EnableIRQ(EXTI15_10_IRQn);

}

/* USER CODE BEGIN 4 */

/* USER CODE END 4 */

/**
  * @brief  This function is executed in case of error occurrence.
  * @retval None
  */
void Error_Handler(void)
{
  /* USER CODE BEGIN Error_Handler_Debug */
  /* User can add his own implementation to report the HAL error return state */
  __disable_irq();
  while (1)
  {
  }
  /* USER CODE END Error_Handler_Debug */
}

#ifdef  USE_FULL_ASSERT
/**
  * @brief  Reports the name of the source file and the source line number
  *         where the assert_param error has occurred.
  * @param  file: pointer to the source file name
  * @param  line: assert_param error line source number
  * @retval None
  */
void assert_failed(uint8_t *file, uint32_t line)
{
  /* USER CODE BEGIN 6 */
  /* User can add his own implementation to report the file name and line number,
     ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */
  /* USER CODE END 6 */
}
#endif /* USE_FULL_ASSERT */
