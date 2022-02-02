/*
 * demo-pdm.S
 *
 * Firmware for testing the PDM output hardware and its FIFO.
 * It pushes out about 8 kSps and generates a sine wave on one
 * channel and a triangle wave on the other channel.
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
	nop
	sw zero, 0(a1)
	addi    a1, a1, 4
	bne	a1, a2, 1b

	// Auto ---
	li s3, 0x0100
	sw s3, IOCONF_OFS(18)
	li s3, 0x0218
	sw s3, IOCONF_OFS(19)
	li s3, 0x0030
	sw s3, IOCONF_OFS(20)

	// Trigger load
	li s0, 1
	sw s0, 0(a0)

1:
	lw s0, 0(a0)
	bne s0, zero, 1b


	// Copy data table to SRAM
	la a0, data
	la a1, data_end
	li a2, 0x30400000
1:
	nop
	lw s0, 0(a0)
	sw s0, 0(a2)
	addi a0, a0, 4
	addi a2, a2, 4
	bne a0, a1, 1b

	// Audio init
	li a0, 0x30200000

	li s0, 1
	sw s0, 0(a0)		// Run

	li s0, 669-2
	sw s0, 4(a0)		// Div (669 -> ~ 9.4 kHz)

	li s0, 0x7fff7fff
	sw s0, 8(a0)		// Volume

	// a0 = Audio base
	// a1 = Data base
	// a2 = Compute index
	// s0 = Accumulator
	// s1 = Data word

	li a1, 0x30400000
	li s0, 0

1:
	nop

	// Wait for space in FIFO
	lb s2, 1(a0)
	bne s2, zero, 1b

	// Load and write data
	add a2, a1, s0
	lw  s1,  0(a2)
	sw  s1, 12(a0)

	// Next word
	addi s0, s0, 6*4
	andi s0, s0, 0x1fc

	// Loop
	j 1b

data:
	.word 0x00008001
	.word 0x06488401
	.word 0x0c8c8801
	.word 0x12c88c01
	.word 0x18f99001
	.word 0x1f1a9401
	.word 0x25289801
	.word 0x2b1f9c01
	.word 0x30fba001
	.word 0x36baa401
	.word 0x3c56a801
	.word 0x41ceac01
	.word 0x471cb001
	.word 0x4c3fb401
	.word 0x5133b801
	.word 0x55f5bc01
	.word 0x5a82c000
	.word 0x5ed7c400
	.word 0x62f1c800
	.word 0x66cfcc00
	.word 0x6a6dd000
	.word 0x6dc9d400
	.word 0x70e2d800
	.word 0x73b5dc00
	.word 0x7641e000
	.word 0x7884e400
	.word 0x7a7ce800
	.word 0x7c29ec00
	.word 0x7d89f000
	.word 0x7e9cf400
	.word 0x7f61f800
	.word 0x7fd8fc00
	.word 0x7fff0000
	.word 0x7fd80400
	.word 0x7f610800
	.word 0x7e9c0c00
	.word 0x7d891000
	.word 0x7c291400
	.word 0x7a7c1800
	.word 0x78841c00
	.word 0x76412000
	.word 0x73b52400
	.word 0x70e22800
	.word 0x6dc92c00
	.word 0x6a6d3000
	.word 0x66cf3400
	.word 0x62f13800
	.word 0x5ed73c00
	.word 0x5a824000
	.word 0x55f543ff
	.word 0x513347ff
	.word 0x4c3f4bff
	.word 0x471c4fff
	.word 0x41ce53ff
	.word 0x3c5657ff
	.word 0x36ba5bff
	.word 0x30fb5fff
	.word 0x2b1f63ff
	.word 0x252867ff
	.word 0x1f1a6bff
	.word 0x18f96fff
	.word 0x12c873ff
	.word 0x0c8c77ff
	.word 0x06487bff
	.word 0x00007fff
	.word 0xf9b87bff
	.word 0xf37477ff
	.word 0xed3873ff
	.word 0xe7076fff
	.word 0xe0e66bff
	.word 0xdad867ff
	.word 0xd4e163ff
	.word 0xcf055fff
	.word 0xc9465bff
	.word 0xc3aa57ff
	.word 0xbe3253ff
	.word 0xb8e44fff
	.word 0xb3c14bff
	.word 0xaecd47ff
	.word 0xaa0b43ff
	.word 0xa57e4000
	.word 0xa1293c00
	.word 0x9d0f3800
	.word 0x99313400
	.word 0x95933000
	.word 0x92372c00
	.word 0x8f1e2800
	.word 0x8c4b2400
	.word 0x89bf2000
	.word 0x877c1c00
	.word 0x85841800
	.word 0x83d71400
	.word 0x82771000
	.word 0x81640c00
	.word 0x809f0800
	.word 0x80280400
	.word 0x80010000
	.word 0x8028fc00
	.word 0x809ff800
	.word 0x8164f400
	.word 0x8277f000
	.word 0x83d7ec00
	.word 0x8584e800
	.word 0x877ce400
	.word 0x89bfe000
	.word 0x8c4bdc00
	.word 0x8f1ed800
	.word 0x9237d400
	.word 0x9593d000
	.word 0x9931cc00
	.word 0x9d0fc800
	.word 0xa129c400
	.word 0xa57ec000
	.word 0xaa0bbc01
	.word 0xaecdb801
	.word 0xb3c1b401
	.word 0xb8e4b001
	.word 0xbe32ac01
	.word 0xc3aaa801
	.word 0xc946a401
	.word 0xcf05a001
	.word 0xd4e19c01
	.word 0xdad89801
	.word 0xe0e69401
	.word 0xe7079001
	.word 0xed388c01
	.word 0xf3748801
	.word 0xf9b88401
data_end:
