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
	cmp r0,r1	@ r0(100)-r1(34)= N,Z,C,V,Q
@ after N=0, Z=0, C=1, V=0
	bge 1f
	blt 2f
1:
	@mov r0,r0
	bx lr
2:
	mov r0,r1
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

	 /*
	 	int clear_unused(int v, int bitnum)
	 	------------------------
	 	r0=v(0xffffffff), r1=bitnum(0)
	 	The return value is result (r0)
		*/
	.global  clear_unused
clear_unused:
	@ IMPLEMENT HERE
	@ returning v & ~(1<<bitnum);
	@ use MOV, LSL and BIC instruction: under 5 lines
	mov r2,#1
	lsl r2,r1
	bic r0,r2
	bx lr

	 /*
	 	int clears_unused(int v, int pattern)
	 	------------------------
	 	r0=v(0xffffffff), r1=pattern(0)
	 	The return value is result (r0)
		*/
	.global  clears_unused
clears_unused:
	@ IMPLEMENT HERE
	@ returning v & ~(pattern);
	@ use BIC instruction: under 5 lines
	bic r0,r1
	bx lr

	 /*
	 	int sum(int start, int end)
	 	------------------------
			r0=start, r1=end
			The return value is sum (r0)
		*/
	.global  sum
sum:
	@ IMPLEMENT HERE
	@ use MOV, ADD, CMP and B instruction: under 10 lines
	mov r2,#0 @sum(r2)
loop1:
	add r2,r0
	add r0,#1
	cmp r1,r0
	bge loop1
	mov r0,r2 @return value
	bx lr	 @ return

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
