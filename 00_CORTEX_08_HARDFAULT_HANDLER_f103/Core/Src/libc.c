/*
 * libc.c
 *
 *  Created on: 2022. 3. 20.
 *      Author: admin
 */

#include <stdio.h>
#include <stdint.h>

uint8_t ReadMem(uint32_t* pulMemAddr, int ulLength);

void mem32set (void *dest, int val, size_t len)
{
  unsigned int *ptr = dest;
  while (len-- > 0)
    *ptr++ = val;
}

void dump_m(uint32_t* pulMemAddr)
{
	uint8_t* pucRegister;
	int i;

	pucRegister = (uint8_t*)((unsigned long)pulMemAddr);

	printf("-----------------------------------------------------------\n");
	printf("  Address   0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f\n");
	for(i=0; i<16; i++)
	{
		printf("%p ", &pucRegister[i*16]);
		printf("%02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x %02x\n", ReadMem((uint32_t*)(&pucRegister[i*16+0]), 1), ReadMem((uint32_t*)(&pucRegister[i*16+1]), 1), ReadMem((uint32_t*)(&pucRegister[i*16+2]), 1), ReadMem((uint32_t*)(&pucRegister[i*16+3]), 1), ReadMem((uint32_t*)(&pucRegister[i*16+4]), 1), ReadMem((uint32_t*)(&pucRegister[i*16+5]), 1), ReadMem((uint32_t*)(&pucRegister[i*16+6]), 1), ReadMem((uint32_t*)(&pucRegister[i*16+7]), 1), ReadMem((uint32_t*)(&pucRegister[i*16+8]), 1), ReadMem((uint32_t*)(&pucRegister[i*16+9]), 1), ReadMem((uint32_t*)(&pucRegister[i*16+10]), 1), ReadMem((uint32_t*)(&pucRegister[i*16+11]), 1), ReadMem((uint32_t*)(&pucRegister[i*16+12]), 1), ReadMem((uint32_t*)(&pucRegister[i*16+13]), 1), ReadMem((uint32_t*)(&pucRegister[i*16+14]), 1), ReadMem((uint32_t*)(&pucRegister[i*16+15]), 1));
	}
	printf("-----------------------------------------------------------\n\n");

}

/*	----------------------------------------------------------------------------
	FUNCTION:		ReadMem
	MT-LEVEL:		[MT-Safe | Safe | UnSafe ]
	DESCRIPTION:

	PARAMETERS:
					uint32_t* pulRegister, uint32_t ulValue
	REMARK:

	RETURN VALUES:
					void :
	ERRORS:

	SEE ALSO:
	----------------------------------------------------------------------------
*/
uint8_t ReadMem(uint32_t* pulMemAddr, int ulLength)
{
	uint32_t* pulRegister = pulMemAddr;
	uint16_t* puwRegister = (uint16_t*)pulMemAddr;
	uint8_t* pucRegister = (uint8_t*)pulMemAddr;

	uint8_t ulRValue = -1;

	switch(ulLength)
	{
	case 1:
		ulRValue = *pucRegister;
		break;
	case 2:
		ulRValue = *puwRegister;
		break;
	case 4:
		ulRValue = *pulRegister;
		break;
	}

	return(ulRValue);
}

