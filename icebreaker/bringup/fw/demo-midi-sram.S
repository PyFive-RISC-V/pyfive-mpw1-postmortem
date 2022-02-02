/*
 * demo-midi-sram.S
 *
 * Firmware for testing the output side of the MIDI UART.
 * It just continuously sends a string.
 * This variant first copies the string to local SRAM to speed
 * up the process.
 *
 * Copyright (C) 2021-2022  Sylvain Munaut <tnt@246tNt.com>
 * SPDX-License-Identifier: MIT
 */

#define IOCONF_BASE	0x26000000
#define IOCONF_OFS(x)	(0x20 + 4 * (x))(a0)

	.section .text.start
	.global _start
_start:
	// Set configuration
	li a0, IOCONF_BASE

	// Clear all registers
	li a1, 0x26000020
	li a2, 0x260000b8

1:
	sw zero, 0(a1)
	addi    a1, a1, 4
	bne	a1, a2, 1b

	// Auto ---
	li s3, 0x0020
	sw s3, IOCONF_OFS(16)
	li s3, 0x0013
	sw s3, IOCONF_OFS(17)

	// Trigger load
	li s0, 1
	sw s0, 0(a0)

1:
	lw s0, 0(a0)
	bne s0, zero, 1b


	// SRAM init
		// Base
	li a2, 0x30400000

		// Copy string to it
	la a1, str
	mv a3, a2
1:
	lb s0, 0(a1)
	sb s0, 0(a3)
	addi a1, a1, 1
	addi a3, a3, 1
	bne s0, zero, 1b

	// Midi
	li a0, 0x30100000

	li s0, 10
	sw s0, 4(a0)	// DIV

print:
	mv a1, a2
1:
	lb s0, 0(a1)
	beq s0, zero, 2f
	sw s0, 0(a0)	// Data
	sw s0, 0(a0)	// Data
	sw s0, 0(a0)	// Data
	sw s0, 0(a0)	// Data
	addi a1, a1, 1
	j 1b
2:
	nop		// NOP needed to avoid crash ...
	j print


	// Infinite loop
1:
	nop
	nop
	nop
	j 1b


str:	.asciz "Hello from MPW-1"

