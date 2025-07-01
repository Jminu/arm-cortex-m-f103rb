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

.macro printf_svc0
	svc 0x0
.endm

.macro printf_svc01
	svc 0x1
.endm

.macro clear_qflag
	mrs r2, APSR
	bic r2, #1 << 27
	msr APSR_nzcvq, r2
.endm

	 /*
	 	void ASM_FUNC1(void)
	 	------------------------
		*/
	.global  ASM_FUNC1
ASM_FUNC1:

#if 0
	/*
		Example of usage of the b instruction (global label method)
		*/
	nop
	b lbl01
	nop
lbl01:
	nop
	b lbl02
lbl03:
	b _exit1
	nop
	.space 2100000
lbl02:
	b lbl03
	nop
_exit1:
	bx lr
#endif

#if 0
	/*
		Restrictions on the b instruction
		Let's add the code at line number 49
			.space 10 good! => b.n lbl03
		Let's add the code at line number 49
			.space 1000000 good! => b.w lbl03
		Let's add the code at line number 49
			.space 2100000 bad! = > FAIL
		*/
#endif

#if 0
	/*
		Example of using the b instruction (local label method)
		*/
	nop
	b 1f
	nop
1:
	nop
	b 2f
1:
	b _exit1
	nop
	nop
2:
	b 1b
	nop
_exit1:
	bx lr
#endif

#if 0
/*
 * Data processing instructions
 */
	@ check C(carry) flag bit
	mov r0, #-1
	add r0, #1
	printf_svc0

	@ check N(negative) & V(overflow) flag bit
	ldr r0, =0x7fffffff
	adds r0, #1
	printf_svc0

	@ check C(carry) & Z(zero) flag bit
	mov r0, #-1
	adds r0, #1
	printf_svc0

	@ Add the register value and the C flag to the register value.
	mov r0, #1
	adcs r0, #1
	printf_svc0

	@ get PC-relative Address
	adr r2, MY_WORDS
	ldr r0, [r2]
	printf_svc0

	@ Bitwise AND
	mov r0, #-1
	and r0, #4
	printf_svc0

	@ Bitwise AND & thumb2
	mov r1, #-1
	and r0, r1, #0xf40 @implicit
	and.w r0, r1, #0xf40 @explicit
	printf_svc0

	@ Bitwise Bit Clear
	mov r1, #-1
	bic r0, r1, #0xc0000000
	bics r0, r1, #3 << 30
	printf_svc0

	@ compare & check flags
	mov r0, #0
	cmp r0, #0
	printf_svc0

	@ compare 2's complement value & check flags.
	@ cmn a, b @ a-(-b)
	mov r0, #1
	cmn r0, #-1
	printf_svc0

	@ Bitwise Exclusive OR
	mov r0, #-1
	eor r0, #8 @ toggle
	eor r0, #8 @ toggle
	printf_svc0

	@ Bitwise NOT
	mov r0, #-1
	mvns r0, r0 @ 0xffff.ffff
	printf_svc0

	@ Bitwise OR NOT
	mov r0, #0
	orns r0, #0xff00 @ 0xffff.00ff
	printf_svc0

	@ Bitwise OR
	mov r0, #0
	orrs r0, #0xff00 @ 0x0000.ff00
	printf_svc0

	@ Subtract
	mov r0, #1
	mov r1, #2
	subs r0, r1	@ 0xffffffff
	printf_svc0

	@ Reverse Subtract
	mov r0, #1
	mov r1, #2
	rsbs r0, r1	@ 0x00000001
	printf_svc0

	@ Subtract with Carry
	mov r0, #1
	mov r1, #2
	sbcs r0, r1	@ 0xffffffff
	printf_svc0

	@ Test Equivalence
	@ Used to check only whether values ​​match
	mov r0, #0x44
	teq r0, #0x44	@ true, Z=1
	printf_svc0

	@ Test
	@ Check a specific bit and if true, note that Z = 0
	mov r0, #0x8000
	tst r0, #1 << 15	@ true, Z=0
	printf_svc0
#endif

#if 0
/*
 * Branch instructions
 */
	adr r0, function1+1 @ PC's lsb is always '1'
	blx r0 @ Branch with link and exchange (Call) to a address stored in R0
	printf_svc0
#endif

#if 0
/*
 * Shift instructions
 */
	@ lsl
	mov r0, #1
	lsl r0, #15
	printf_svc0

	@ lsl & carry set
	mov r0, #0x80000000
	lsls r0, #1 @ C=1, Z=1
	printf_svc0

	@ lsl & by 2^1 multiply
	mov r0, #-40
	lsls r0, #1 @ C=1, N=1
	printf_svc0

	@ lsr & by 2^1 divide
	mov r0, #-80
	lsrs r0, #1 @ C=1, Z=1
	printf_svc0

	@ asr & by 2^1 divide
	mov r0, #-80
	asrs r0, #1 @ C=1, Z=1
	printf_svc0

	@ rotate right & carry set
	mov r0, #1
	rors r0, #1 @ C=1, N=1
	printf_svc0

	@ rotate right with extend & carry set
	mov r1, #0xf
	rrx r0, r1 @ C=1, N=1
	printf_svc0
#endif

#if 0
/*
 * Multiply instructions
 */
 @ Signed Multiply Long
 	mov r0, #0
 	mov r1, #0
 	mov r2, #0x0F000
 	mov r3, #0x80000
	smull r0, r1, r2, r3
	printf_svc0

 @ Signed Multiply Accumulate Long
 	mov r0, #0x77
 	mov r1, #0
 	mov r2, #0x0F000
 	mov r3, #0x80000
	smlal r0, r1, r2, r3
	printf_svc0
#endif

#if 0
/*
 * Saturating instructions
 */
 	@ Signed Saturating instructions & Q flag set
 	mov r1, #0x00020000
 	ssat r0, #16, r1 @ Q=1 or 0
 	clear_qflag

 	mov r1, #0x00008000
 	ssat r0, #16, r1 @ Q=1 or 0
 	clear_qflag

 	mov r1, #0x00007fff
 	ssat r0, #16, r1 @ Q=1 or 0
 	clear_qflag

 	mov r1, #0x00000000
 	ssat r0, #16, r1 @ Q=1 or 0
 	clear_qflag

 	ldr r1, =0xFFFF8000
 	ssat r0, #16, r1 @ Q=1 or 0
 	clear_qflag

 	ldr r1, =0xFFFF8001
 	ssat r0, #16, r1 @ Q=1 or 0
 	clear_qflag

 	ldr r1, =0xFFFE0000
 	ssat r0, #16, r1 @ Q=1 or 0
	clear_qflag

 	@ Unsigned Saturating instructions & Q flag set
 	mov r1, #0x00020000
 	usat r0, #16, r1 @ Q=1 or 0
	clear_qflag

 	mov r1, #0x00008000
 	usat r0, #16, r1 @ Q=1 or 0
	clear_qflag

 	mov r1, #0x00007fff
 	usat r0, #16, r1 @ Q=1 or 0
	clear_qflag

 	mov r1, #0x00000000
 	usat r0, #16, r1 @ Q=1 or 0
	clear_qflag

 	ldr r1, =0xFFFF8000
 	usat r0, #16, r1 @ Q=1 or 0
	clear_qflag

 	ldr r1, =0xFFFF8001
 	usat r0, #16, r1 @ Q=1 or 0
	clear_qflag

 	ldr r1, =0xFFFFFFFF
	usat r0, #16, r1 @ Q=1 or 0
	clear_qflag
#endif

#if 0
/*
 * Packing and unpacking instructions
 */
 	@ Signed Extend Byte
	ldr r1, =0x1234abcd
	sxtb r0,r1
	printf_svc0

	@ Unsigned Extend Byte
	ldr r1, =0x1234abcd
	uxtb r0,r1
	printf_svc0
	bkpt 0x99
#endif

#if 0
/*
 * Divide instructions
 */
	@ Signed Divide
	ldr r0, =-1200
	mov r1, #5
	sdiv r0, r0, r1
	printf_svc0

	@ Unsigned Divide
	ldr r0, =-1200
	mov r1, #5
	udiv r0, r0, r1
	printf_svc0

	@ Divide by zero
	@ // ignore fault by divide by zero
	@ SCB->CCR &= ~SCB_CCR_DIV_0_TRP_Msk;
	ldr r0, =-1200
	mov r1, #0
	sdiv r0, r0, r1
	printf_svc0
#endif

#if 0
/*
 * Parallel addition and subtraction instructions
 */
	@ Signed Add 8 performs four 8-bit signed integer additions
	ldr r1,=0x12345678
	ldr r2,=0x11111111
	sadd8 r0,r1,r2
	printf_svc0

	@ Saturating Add 8-bit
	ldr r1,=0x12345678
	ldr r2,=0x55555555
	qadd8 r0,r1,r2
	printf_svc0
#endif

#if 0
/*
 * Miscellaneous data-processing instructions
 */
 	@ Bit Field Clear
	ldr r0, =0x12345678
	bfc r0, #4, #16
	printf_svc0

 	@ Bit Field Insert
 	ldr r0, =0xffffffff
	ldr r1, =0x12345678
	bfi r0, r1, #4, #16
	printf_svc0

	@ Count Leading Zeros
	mov r1, 0x00040000
	mov r2, #31
	clz r0, r1
	sub r0, r2, r0
	printf_svc0

	@ Move Top
	ldr r0, =0x12345678
	movt r0, #0xffff
	printf_svc0

	@ Move Top & Bottom
	movw r0, #0x5555
	movt r0, #0xaaaa
	printf_svc0

	@ Reverse Bits
	ldr r0,=0x80300000
	rbit r0, r0
	printf_svc0

	@ Byte-Reverse Word
	ldr r0,=0x12345678
	rev r0, r0
	printf_svc0

	@ Byte-Reverse Packed Halfword
	ldr r0,=0x12345678
	rev16 r0, r0
	printf_svc0

	@ Byte-Reverse Signed Halfword
	ldr r0,=0x12345678
	revsh r0, r0
	printf_svc0

	ldr r0,=0x123456FF
	revsh r0, r0
	printf_svc0

	@ Signed Bit Field Extract
	ldr r1,=0x12ABCD78
	sbfx r0, r1, #8, #16
	printf_svc0

	@ Unsigned Bit Field Extract
	ldr r1,=0x12ABCD78
	ubfx r0, r1, #8, #16
	printf_svc0
#endif

#if 0
/*
 * System instruction
 */
	@ Change Processor State
	cpsid i	@ disable primask
	cpsie i	@ enable primask
	cpsid f	@ disable faultmask
	cpsie f	@ enable faultmask

	@ Move to/from Special Register
	mov r0, #1
	msr primask, r0	@ set primask
	mrs r1, primask @ get primask
#endif

#if 1
/*
 * Load and store instructions
 */
	@ load basic
	ldr r1, =libs_sector
	ldr r0, [r1]
	ldr r0, [r1, #4]	@ pre-indexed addressing
	ldr r0, [r1, #4]! @ pre-indexed addressing
	ldr r0, [r1], #4	@ post-indexed addressing
	ldr r0, [r1], #4

	@ store basic
	ldr r2, =0xdeadbeef
	ldr r1, =libs_sector
	str r2, [r1]
	str r2, [r1, #4] @ pre-indexed addressing
	str r2, [r1, #4]!
	str r2, [r1], #4 @ post-indexed addressing
	str r2, [r1], #4

	@ byte/half word access
	ldr r2, =0x1234abcd
	ldr r1, =libs_sector
	strb r2, [r1], #1
	strb r2, [r1], #1
	strb r2, [r1], #1
	strb r2, [r1], #1
	strh r2, [r1], #2
	strh r2, [r1], #2

	ldr r1, =libs_sector
	ldr r2, =0x1234abcd
	str r2, [r1], #4
	str r2, [r1], #4
	ldr r1, =libs_sector
	ldrb r0, [r1], #1
	ldrb r0, [r1], #1
	ldrb r0, [r1], #1
	ldrb r0, [r1], #1
	ldrsb r0, [r1], #1
	ldrsb r0, [r1], #1
	ldrsb r0, [r1], #1
	ldrsb r0, [r1], #1
#endif

	@ endless loop
	b .

/*
 * function1
 */
function1:
	mov r0, #0x99
	bx lr

MY_WORDS:
.word 0x12345678
.word 0x5555AAAA

	b	.  /* b	is goto, DOT indicates current location */

   .section  .libs_sector,"a"
  .type  libs_sector, %object
@ int libs_sector[]={ 0x12345678, 0x1555aaaa, 0x1555aaaa, ..... }
libs_sector:
  .word 0x12345678
  .word	0x1555aaaa
  .word	0x2555aaaa
  .word	0x3555aaaa
  .word	0x4555aaaa
  .word	0x5555aaaa
  .word	0x6555aaaa
  .word	0x7555aaaa
  .word	0x8555aaaa
  .word	0x9555aaaa
  .word	0x0555aaaa

