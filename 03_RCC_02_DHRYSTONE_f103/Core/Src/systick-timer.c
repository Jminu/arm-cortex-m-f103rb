// SPDX-License-Identifier: GPL-2.0+
/*
 * ARM Cortex M3/M4/M7 SysTick timer driver
 * (C) Copyright 2017 Renesas Electronics Europe Ltd
 *
 * Based on arch/arm/mach-stm32/stm32f1/timer.c
 * (C) Copyright 2015
 * Kamil Lulko, <kamil.lulko@gmail.com>
 *
 * Copyright 2015 ATS Advanced Telematics Systems GmbH
 * Copyright 2015 Konsulko Group, Matt Porter <mporter@konsulko.com>
 *
 * The SysTick timer is a 24-bit count down timer. The clock can be either the
 * CPU clock or a reference clock. Since the timer will wrap around very quickly
 * when using the CPU clock, and we do not handle the timer interrupts, it is
 * expected that this driver is only ever used with a slow reference clock.
 *
 * The number of reference clock ticks that correspond to 10ms is normally
 * defined in the SysTick Calibration register's TENMS field. However, on some
 * devices this is wrong, so this driver allows the clock rate to be defined
 * using CONFIG_SYS_HZ_CLOCK.
 */

#include "main.h"
#include <stdio.h>

static unsigned long long get_ticks(void);
void dhry(int Number_Of_Runs);

/* Wrapper for do_div(). Doesn't modify dividend and returns
 * the result, not remainder.
 */

/* SysTick Base Address - fixed for all Cortex M3, M4 and M7 devices */
#define SYSTICK_BASE		0xE000E010
#define TIMER_MAX_VAL		0x00FFFFFF
#define HZ	1000

struct time_info {
	uint32_t lastinc;
	uint32_t timer_rate_hz;
	unsigned long long tbl;
};

static struct time_info tm;

/* read the 24-bit timer */
static uint32_t read_timer(void)
{
	/* The timer counts down, therefore convert to an incrementing timer */
	//return TIMER_MAX_VAL - SysTick->VAL;
	return HAL_GetTick();
}

int timer_init(void)
{
	tm.lastinc = read_timer();
	tm.timer_rate_hz = HZ;

	return 0;
}

/* return milli-seconds timer value */
uint64_t get_timer(uint32_t base)
{
	unsigned long long t = get_ticks() * HZ;

	return (uint64_t)((t / tm.timer_rate_hz)) - base;
}

static unsigned long long get_ticks(void)
{
	uint32_t now = read_timer();

	if (now >= tm.lastinc)
		tm.tbl += (now - tm.lastinc);
	else
		tm.tbl += (TIMER_MAX_VAL - tm.lastinc) + now;

	tm.lastinc = now;

	return tm.tbl;
}

int do_dhry(void)
{
	uint32_t start, duration, vax_mips;
	uint64_t dhry_per_sec;
	int iterations = 1000000; //number of repetitions

	timer_init();

	start = get_timer(0);
	dhry(iterations);
	duration = get_timer(start);
//	dhry_per_sec = lldiv(iterations * 1000ULL, duration);
	dhry_per_sec = ((iterations * 1000ULL)/duration);

//	vax_mips = lldiv(dhry_per_sec, 1757);
	vax_mips = (dhry_per_sec/1757);

	printf("%d iterations in %lu ms: %lu/s, %lu DMIPS\n", iterations,
	       duration, (ulong)dhry_per_sec, vax_mips);

	return 0;
}
