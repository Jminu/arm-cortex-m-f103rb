/*
 * libs.s
 *
 *  Created on: 2022. 3. 20.
 *      Author: admin
 */

  .syntax unified
  .cpu cortex-m4
  .fpu softvfp
  .thumb

	.text

	 /*
	 	void FIRST_ASM_FUNC(void)
	 	------------------------
		*/
	.global  FIRST_ASM_FUNC
FIRST_ASM_FUNC:
	@ return to main function
	add a1,a2 @r0=r0+r1
@	add r0,r0,r1 @r0=r0+r1
	bx lr @pc=lr, LR[0]=1 thumb
@	b	.  /* b	is goto, DOT indicates current location */


	 /*
	 	char ADD8(char a8, char b8)
	 	------------------------
	 	a8: r0, b8: r1
		*/
	.global  ADD8
ADD8:
	@ return the sum of two numbers
	add r0,r1	@r0=r0+r1
	bx lr @return

	 /*
	 	int ADD32(int a, int b)
	 	------------------------
	 	a: r0, b: r1
		*/
	.global  ADD32
ADD32:
	@ return the sum of two numbers
	add r0,r1	@r0=r0+r1
	bx lr

	 /*
	 	int max(int a, int b)
	 	------------------------
	 	a:r0(34), b:r1(100)
		*/
	.global  max
max:
	@ IMPLEMENT HERE
	@ returning the max between two numbers
	@ use MOV, CMP and B instruction
@ before N=0, Z=0, C=0, V=1
	cmp r0,r1	@ r0(34)-r1(100)= N,Z,C,V,Q, @ r0이 기준이다!
@ after N=1, Z=0, C=0, V=0
	bge 1f @ goto label 1
	blt 2f @ goto label 2
1: @pipeline stall
	mov r0,r0 @ 생략가능
	bx lr
2:
	mov r0,r1 @ r1이 더 크다면, AAPCS규칙에 따라, r0으로 옮겨줘야 r1을 반환가능
	bx lr


	.global max_prac
max_prac:
	cmp r0,r1 @ compare with r0, r1 based on r0

	bge 1f @ greator equal
	blt 2f @ less than
1: @ r0가 더 클때
	mov r0, r0
	bx lr
2: @ r1가 더 클때
	mov r0, r1 @ r0이 반환 레지스터이기 때문에 결과를 r0에 저장
	bx lr @ 복귀주소로 복귀


	.global max2_prac
max2_prac:
	cmp r0, r1
	ite ge
	movge r0, r0
	movlt r0, r1
	bx lr

	 /*
	 	int max2(int a, int b)
	 	------------------------
		*/
	.global  max2
max2:
	@ IMPLEMENT HERE
	@ returning the max between two numbers
	@ use MOV, CMP and IT??? instruction: under 6 lines
	@ hint: https://community.arm.com/arm-community-blogs/b/architectures-and-processors-blog/posts/condition-codes-3-conditional-execution-in-thumb-2
	cmp r0,r1
	ite ge
	movge r0,r0
	movlt r0,r1
	bx lr



	.global  clear_unused
clear_unused:
	mov r2,#1 @r2에 숫자 1저장
	lsl r2, r1 @ logical shift left, r1만큼 왼쪽으로 민다
	bic r0, r2 @ bit clean, r0에서 r2의 비트만 clear한다
	bx lr



	.global  clears_unused
clears_unused:
	bic r0, r1 @ r1에 pattern이 온다
	bx lr
/*
	clear_unused는 clear할 비트의 위치를 인자로 전달했고,
	(그래서 1을 left shift해서 bit를 하는듯)
	clears_unused는 그냥 바로 pattern에 해당 되는걸 clear한다
*/



	.global  sum
sum: @ r0 = start, r1 = end
	mov r2, #0 @ r2는 sum, 초기화
loop1:
	add r2, r0
	add r0, #1
	cmp r1, r0 @ start와 end를 비교
	bge loop1 @ r2가 r1보다 크면
	mov r0, r2
	bx lr



	 /*
	 	void MEMCPY_SINGLE(unsigned long dst, unsigned long src, int size)
	 	------------------------
			r0=dst, r1=src, r2=size
		*/
	.global  MEMCPY_SINGLE
MEMCPY_SINGLE:
	push {lr} 	 @ push
	@ IMPLEMENT HERE
	@ use LDR, STR, SUB, CMP and B instruction: under 10 lines
	lsl r2,#2 @ r2=r2*(2^2)=4r2
loop2:
	ldrb r3,[r1],#1
	strb r3,[r0],#1
	sub r2,#1
	cmp r2,#0
	bgt loop2

	pop {pc}	 @ pop(pc=lr), likely bx lr

	 /*
	 	void MEMCPY_BLOCK(unsigned long dst, unsigned long src, int size)
	 	------------------------
			r0=dst, r1=src, r2=size
		*/
	.global MEMCPY_SINGLE_PRAC
MEMCPY_SINGLE_PRAC: @ r0=dst, r1=src, r2=size:16
	push {lr}

	lsl r2, #2 @ r2=size: 64 -> 왼쪽으로 2번 쉬프트했기 때문에,
loop2:
	ldrb r3, [r1], #1 @ r3에 r1이 가리키는 주소에 저장된 값을 load하고, r1을 word만큼 증가 -> 읽고, 포인터 증가하고
	strb r3, [r0], #1 @ r0이 가리키는 주소에 r3값을 str하고, r0을 word만큼 증가 -> 쓰고, 포인터 증가하고
	sub r2, #1 @ 16번 반복할거임, 계속 1씩 빼간
	cmp r2, #0 @ 0하고 비교
	bgt loop2 @ 반복할게 남았다면, loop2로 복귀

	pop {pc}



	.global  MEMCPY_BLOCK
MEMCPY_BLOCK:
	push {r4-r6,lr} 	 @ push
	@ IMPLEMENT HERE
	@ Make a copy in units of 4 words
	@ use LDMIA, STMIA, SUB and CBZ instruction: under 10 lines

loop3:
	cbz r2,_exit_MEMCPY_BLOCK
	ldmia r1!,{r3-r5,r6}
	stmia r0!,{r3-r5,r6}
	sub r2,#4
	b loop3
_exit_MEMCPY_BLOCK:
	pop {r4-r6,pc}	 @ pop

	 /*
	 	void __bswap_32_asm(unsigned int a)
	 	------------------------
			r0=a
		*/
	.global  __bswap_32_asm
__bswap_32_asm:
	push {lr} 	 @ push
	@ IMPLEMENT HERE
	@ byte swap by rev
	@ use rev, rev16, revsh OR rbit: under 4 lines
	@rev r0,r0
	@rev16 r0,r0
	@revsh r0,r0
	rbit r0,r0

	pop {pc}	 @ pop

	@
	@ int whereIsBit(int c)
	@	c:r0
	@
	.global whereIsBit
whereIsBit:
	push {lr}
	@ IMPLEMENT HERE
	@ use clz: under 7 lines
	mov r1,#31
	clz r0,r0
	sub r1,r0
	mov r0,r1
	pop {pc}

	@
	@ int MY_LL_GPIO_TogglePin(void)
	@
	@
	.global MY_LL_GPIO_TogglePin
MY_LL_GPIO_TogglePin:
	push {lr}

	pop {pc}

	/*
	-------------------------
	*
	* xPSR
	* Example for explaining PSR register bits
	*
	*/
	.global xPSR_TEST
xPSR_TEST:

	// N-flag
	mov r0,#0x80000000
	subs r0,#1 @ N(0):0x7FFFFFFF
	adds r0,#1 @ N(1):0x80000000
	// Z-flag
	mov r0,#2
	subs r0,#1 @ Z(0)
	subs r0,#1 @ Z(1)
	// C-flag
	mov r0,#-1
	adds r0,#1 @ C(1)
	mov r0,#0x40000000
	lsls r0,#1 @ C(0)
	lsls r0,#1 @ C(1)
	mov r0,#2
	lsrs r0,#1 @ C(0)
	lsrs r0,#1 @ C(1)
	// V-flag
	mov r0,#0x80000000 @ V
	adds r0,#1 @ V(0):0x80000001
	subs r0,#2 @ V(1):0x7FFFFFFF
	adds r0,#1 @ V(1):0x80000000
	// Q-flag
	mov r1,#1
	mov r0,#0x80000000
	subs r0,#1 @ 0x7FFFFFFF
/*
	divide by zero error is occured!
	Note that this symptom does not occur in cortex-m4.
	*/
@	qadd r0,r0,r1 @ Q(1):0x7FFFFFFF

	bx lr
