/*
 * demo-video.S
 *
 * Firmware for testing the video output hardware.
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
	li s3, 0x00c0
	sw s3, IOCONF_OFS(22)
	li s3, 0x0380
	sw s3, IOCONF_OFS(23)
	li s3, 0x0600
	sw s3, IOCONF_OFS(24)
	li s3, 0x0c00
	sw s3, IOCONF_OFS(25)
	li s3, 0x1800
	sw s3, IOCONF_OFS(26)
	li s3, 0x1000
	sw s3, IOCONF_OFS(27)
	li s3, 0x0001
	sw s3, IOCONF_OFS(28)
	li s3, 0x0003
	sw s3, IOCONF_OFS(29)
	// ---

	// Trigger load
	li s0, 1
	sw s0, 0(a0)

1:
	lw s0, 0(a0)
	bne s0, zero, 1b


	// Video
	li a0, 0x30300000

		// Clear control
	li s0, 0
	sw s0, 0(a0)

		// Palette default
	li a1, 0x6000
	add a1, a1, a0
	addi a2, a1, 64
	li s0, 0x0
1:
	nop
	sw s0, 0(a1)
	addi a1, a1, 4
	addi s0, s0, 1
	bne a1, a2, 1b

		// Palette override
	li a1, 0x6000
	add a1, a1, a0

	li s0, 0xf
	sw s0, 0(a1)	// Color 0

	li s0, 0x9
	sw s0, 4(a1)	// Color 1

		// Screen clear
	li a1, 0xc000
	add a1, a1, a0

	li a2, 0xc800
	add a2, a2, a0

1:
	nop
	sw zero, 0(a1)
	addi a1, a1, 4
	bne a1,a2,1b

		// Screen load
	li a1, 0xc000
	add a1, a1, a0

li s0, 0x00888000
sw s0, (0*72)(a1)
li s0, 0x01010203
sw s0, (0*72+48+0)(a1)
li s0, 0x00000302
sw s0, (0*72+4)(a1)
li s0, 0x00888000
sw s0, (1*72)(a1)
li s0, 0x04040506
sw s0, (1*72+48+0)(a1)
li s0, 0x00000605
sw s0, (1*72+4)(a1)
li s0, 0x00888000
sw s0, (2*72)(a1)
li s0, 0x07070809
sw s0, (2*72+48+0)(a1)
li s0, 0x00000908
sw s0, (2*72+4)(a1)
li s0, 0x00888000
sw s0, (3*72)(a1)
li s0, 0x0a0a0b0c
sw s0, (3*72+48+0)(a1)
li s0, 0x00000c0b
sw s0, (3*72+4)(a1)
li s0, 0x00888000
sw s0, (4*72)(a1)
li s0, 0x0d0d0e0f
sw s0, (4*72+48+0)(a1)
li s0, 0x00000f0e
sw s0, (4*72+4)(a1)
li s0, 0x00888000
sw s0, (5*72)(a1)
li s0, 0x10101112
sw s0, (5*72+48+0)(a1)
li s0, 0x00001211
sw s0, (5*72+4)(a1)
li s0, 0x00888000
sw s0, (6*72)(a1)
li s0, 0x13131415
sw s0, (6*72+48+0)(a1)
li s0, 0x00001514
sw s0, (6*72+4)(a1)
li s0, 0x00888000
sw s0, (7*72)(a1)
li s0, 0x16161718
sw s0, (7*72+48+0)(a1)
li s0, 0x00001817
sw s0, (7*72+4)(a1)
li s0, 0x00888000
sw s0, (8*72)(a1)
li s0, 0x19191a1b
sw s0, (8*72+48+0)(a1)
li s0, 0x00001b1a
sw s0, (8*72+4)(a1)
li s0, 0x00888000
sw s0, (9*72)(a1)
li s0, 0x1c1c1d1e
sw s0, (9*72+48+0)(a1)
li s0, 0x00001e1d
sw s0, (9*72+4)(a1)
li s0, 0x00888000
sw s0, (10*72)(a1)
li s0, 0x1f1f2021
sw s0, (10*72+48+0)(a1)
li s0, 0x00002120
sw s0, (10*72+4)(a1)
li s0, 0x00888000
sw s0, (11*72)(a1)
li s0, 0x22222324
sw s0, (11*72+48+0)(a1)
li s0, 0x00002423
sw s0, (11*72+4)(a1)
li s0, 0x00888000
sw s0, (12*72)(a1)
li s0, 0x25252627
sw s0, (12*72+48+0)(a1)
li s0, 0x00002726
sw s0, (12*72+4)(a1)
li s0, 0x00888000
sw s0, (13*72)(a1)
li s0, 0x2828292a
sw s0, (13*72+48+0)(a1)
li s0, 0x00002a29
sw s0, (13*72+4)(a1)
li s0, 0x00888000
sw s0, (14*72)(a1)
li s0, 0x2b2b2c2d
sw s0, (14*72+48+0)(a1)
li s0, 0x00002d2c
sw s0, (14*72+4)(a1)
li s0, 0x00888000
sw s0, (15*72)(a1)
li s0, 0x2e2e2f30
sw s0, (15*72+48+0)(a1)
li s0, 0x0000302f
sw s0, (15*72+4)(a1)
li s0, 0x00888000
sw s0, (16*72)(a1)
li s0, 0x31313233
sw s0, (16*72+48+0)(a1)
li s0, 0x00003332
sw s0, (16*72+4)(a1)
li s0, 0x00888000
sw s0, (17*72)(a1)
li s0, 0x34343536
sw s0, (17*72+48+0)(a1)
li s0, 0x00003635
sw s0, (17*72+4)(a1)
li s0, 0x00888000
sw s0, (18*72)(a1)
li s0, 0x37373839
sw s0, (18*72+48+0)(a1)
li s0, 0x00003938
sw s0, (18*72+4)(a1)
li s0, 0x00888000
sw s0, (19*72)(a1)
li s0, 0x3a3a3b3c
sw s0, (19*72+48+0)(a1)
li s0, 0x00003c3b
sw s0, (19*72+4)(a1)
li s0, 0x00888000
sw s0, (20*72)(a1)
li s0, 0x3d3d3e3f
sw s0, (20*72+48+0)(a1)
li s0, 0x00003f3e
sw s0, (20*72+4)(a1)
li s0, 0x00888000
sw s0, (21*72)(a1)
li s0, 0x40404142
sw s0, (21*72+48+0)(a1)
li s0, 0x00004241
sw s0, (21*72+4)(a1)
li s0, 0x00888000
sw s0, (22*72)(a1)
li s0, 0x43434445
sw s0, (22*72+48+0)(a1)
li s0, 0x00004544
sw s0, (22*72+4)(a1)
li s0, 0x00888000
sw s0, (23*72)(a1)
li s0, 0x46464748
sw s0, (23*72+48+0)(a1)
li s0, 0x00004847
sw s0, (23*72+4)(a1)

		// CHAR clear
	li a1, 0x8000
	add a1, a1, a0

	li a2, 0x8400
	add a2, a2, a0

1:
	nop
	sw zero, 0(a1)
	addi a1, a1, 4
	bne a1, a2, 1b

		// CHAR load
	li a1, 0x8000
	add a1, a1, a0

	sw zero, 0(a1)		// 0
	sw zero, 4(a1)

li s0, 0xe0e0e0e0
sw s0, 36(a1)
li s0, 0xe0e0e0e0
sw s0, 56(a1)
li s0, 0xf0f0f0e0
sw s0, 60(a1)
li s0, 0xf0f0f0f0
sw s0, 80(a1)
li s0, 0xf0f0f0f0
sw s0, 84(a1)
li s0, 0x02000000
sw s0, 92(a1)
li s0, 0xf0f0f0f0
sw s0, 104(a1)
li s0, 0xfcf8f8f0
sw s0, 108(a1)
li s0, 0x0f060606
sw s0, 112(a1)
li s0, 0x1f1f0f0f
sw s0, 116(a1)
li s0, 0x80000000
sw s0, 124(a1)
li s0, 0xfffffefe
sw s0, 128(a1)
li s0, 0xffffffff
sw s0, 132(a1)
li s0, 0x7f3f3f3f
sw s0, 136(a1)
li s0, 0xffffffff
sw s0, 140(a1)
li s0, 0xc0808080
sw s0, 144(a1)
li s0, 0xc0c0c0c0
sw s0, 148(a1)
li s0, 0xffffffff
sw s0, 152(a1)
li s0, 0xffffffff
sw s0, 156(a1)
li s0, 0xffffffff
sw s0, 160(a1)
li s0, 0xffffffff
sw s0, 164(a1)
li s0, 0xc0c0c0c0
sw s0, 168(a1)
li s0, 0x808080c0
sw s0, 172(a1)
li s0, 0xffffffff
sw s0, 176(a1)
li s0, 0xffffffff
sw s0, 180(a1)
li s0, 0xffffffff
sw s0, 184(a1)
li s0, 0xffffffff
sw s0, 188(a1)
li s0, 0x00808080
sw s0, 192(a1)
li s0, 0xffffffff
sw s0, 200(a1)
li s0, 0xffffffff
sw s0, 204(a1)
li s0, 0xfefefeff
sw s0, 208(a1)
li s0, 0xfefefefe
sw s0, 212(a1)
li s0, 0xffffffff
sw s0, 224(a1)
li s0, 0x3f7fffff
sw s0, 228(a1)
li s0, 0xfffffefe
sw s0, 232(a1)
li s0, 0xffffffff
sw s0, 236(a1)
li s0, 0x0f0f1f1f
sw s0, 248(a1)
li s0, 0x07070707
sw s0, 252(a1)
li s0, 0xffffffff
sw s0, 256(a1)
li s0, 0xffffffff
sw s0, 260(a1)
li s0, 0x80000000
sw s0, 264(a1)
li s0, 0xc0808080
sw s0, 268(a1)
li s0, 0x03030303
sw s0, 272(a1)
li s0, 0x03030303
sw s0, 276(a1)
li s0, 0xffffffff
sw s0, 280(a1)
li s0, 0xffffffff
sw s0, 284(a1)
li s0, 0xfefcf8e0
sw s0, 288(a1)
li s0, 0xfefefefe
sw s0, 292(a1)
li s0, 0x01010101
sw s0, 296(a1)
li s0, 0x01010101
sw s0, 300(a1)
li s0, 0xffffffff
sw s0, 304(a1)
li s0, 0xffffffff
sw s0, 308(a1)
li s0, 0xfefefefe
sw s0, 312(a1)
li s0, 0xfefefefe
sw s0, 316(a1)
li s0, 0x01010101
sw s0, 320(a1)
li s0, 0x01010101
sw s0, 324(a1)
li s0, 0xffffffff
sw s0, 328(a1)
li s0, 0xffffffff
sw s0, 332(a1)
li s0, 0xfefefefe
sw s0, 336(a1)
li s0, 0xfefefefe
sw s0, 340(a1)
li s0, 0x03030301
sw s0, 344(a1)
li s0, 0x03030303
sw s0, 348(a1)
li s0, 0xffffffff
sw s0, 352(a1)
li s0, 0xffffffff
sw s0, 356(a1)
li s0, 0xfefefefe
sw s0, 360(a1)
li s0, 0xe0f8fcfe
sw s0, 364(a1)
li s0, 0x07070707
sw s0, 368(a1)
li s0, 0x1f0f0f0f
sw s0, 372(a1)
li s0, 0xffffffff
sw s0, 376(a1)
li s0, 0xffffffff
sw s0, 380(a1)
li s0, 0x808080c0
sw s0, 384(a1)
li s0, 0x00008080
sw s0, 388(a1)
li s0, 0x1f1f1f1f
sw s0, 392(a1)
li s0, 0x0f1f1f1f
sw s0, 396(a1)
li s0, 0xffffffff
sw s0, 400(a1)
li s0, 0xffffffff
sw s0, 404(a1)
li s0, 0x0f0f0f0f
sw s0, 416(a1)
li s0, 0x0f0f0f0f
sw s0, 420(a1)
li s0, 0xfefefefe
sw s0, 424(a1)
li s0, 0xfffefefe
sw s0, 428(a1)
li s0, 0x0707070f
sw s0, 440(a1)
li s0, 0x07070707
sw s0, 444(a1)
li s0, 0xffffffff
sw s0, 448(a1)
li s0, 0xffffffff
sw s0, 452(a1)
li s0, 0x80808000
sw s0, 460(a1)
li s0, 0x03030707
sw s0, 464(a1)
li s0, 0x03030303
sw s0, 468(a1)
li s0, 0xffffffff
sw s0, 472(a1)
li s0, 0xffffffff
sw s0, 476(a1)
li s0, 0xc0808080
sw s0, 480(a1)
li s0, 0xc0c0c0c0
sw s0, 484(a1)
li s0, 0x03030303
sw s0, 488(a1)
li s0, 0x01010101
sw s0, 492(a1)
li s0, 0xffffffff
sw s0, 496(a1)
li s0, 0x3f3fbfff
sw s0, 500(a1)
li s0, 0xc0c0c0c0
sw s0, 504(a1)
li s0, 0x808080c0
sw s0, 508(a1)
li s0, 0x0f0f1f1f
sw s0, 520(a1)
li s0, 0x0606060f
sw s0, 524(a1)
li s0, 0x00000080
sw s0, 528(a1)
li s0, 0x00000002
sw s0, 544(a1)

		// Timing
	li a1, 0x4000
	add a1, a1, a0

	li s0, 0x40000017
	sw s0, 0(a1)		// Sync   (  24 :  96 )

	li s0, 0x0000000b
	sw s0, 4(a1)		// BP     (  12 :  48 )

	li s0, 0x2000001f
	sw s0, 8(a1)		// Border (  32 : 128 )

	li s0, 0x3000005f
	sw s0, 12(a1)		// Active (  96 : 384 )

	li s0, 0x2000001f
	sw s0, 16(a1)		// Border (  32 : 128 )

	li s0, 0x80000003
	sw s0, 20(a1)		// FP     (   4 :  16 )


	li s0, 0x40000001
	sw s0, 32(a1)		// Sync   (   2 )

	li s0, 0x00000020
	sw s0, 36(a1)		// BP     (  33 )

	li s0, 0x2000002f
	sw s0, 40(a1)		// Border (  48 )

	li s0, 0x3000017f
	sw s0, 44(a1)		// Active ( 384 )

	li s0, 0x2000002f
	sw s0, 48(a1)		// Border (  48 )

	li s0, 0x80000009
	sw s0, 52(a1)		// FP     (  10 )

		// Control enable
	li s0, 0x00004001
	sw s0, 0(a0)

	// Infinite loop
1:
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	j 1b
